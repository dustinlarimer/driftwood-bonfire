config = require 'config'
Controller = require './base/controller'
User = require 'models/user'
Profile = require 'models/profile'
UserPageView = require 'views/user/user-page-view'
UserSettingsView = require 'views/user/user-settings-view'
UserSetupView = require 'views/user/user-setup-view'

module.exports = class UsersController extends Controller

  initialize: ->
    super
    @usersRef = Chaplin.mediator.firebase.child('users')
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    @subscribeEvent 'userRegistered', @setup
    console.log 'Users Controller is here'


  show: (params) ->
    @profilesRef.child(params.handle).once "value", (snapshot) =>
      if snapshot.val()?
        @model = new Profile snapshot.val()
        @view = new UserPageView { model: @model, region: 'main' }
        @view.render()
      else
        console.log '#404: this user does not exist'
        # @view = new UserUnavailableView
        # @view.render()


  _settings: ->
    console.log '_settings'
    @model = Chaplin.mediator.user
    @view = new UserSettingsView {model: @model}

  settings: (params) ->
    console.log 'settings'
    if Chaplin.mediator.user?
      if Chaplin.mediator.user.get('profile_id')?
        @_settings
      else
        console.log Chaplin.mediator.user.get('profile_id')
        @redirectTo 'users#setup'
    else
      @subscribeEvent 'login', @_settings


  setup: (params) =>
    # Bail if direct-linked
    return @redirectTo 'home#index' unless Chaplin.mediator.user?
      
    console.log 'Let\'s create a profile for User#' + params.id + ':'
    console.log params

    @model = new Profile {display_name: params.name, handle: params.handle}    
    @view = new UserSetupView {model: @model, region: 'main'}
    @view.bind 'user:create', (data) =>
      console.log 'Creating user profile...'
      newProfile=
        display_name: data.display_name
        user_id: Chaplin.mediator.user.get('id')
      
      @profilesRef.child(data.handle).transaction ((currentProfileData) =>
        newProfile if currentProfileData is null
      ), (error, success, snapshot) =>
        if success
          console.log '[SUCCESS] Profile created: ' + data.handle
          @usersRef.child(Chaplin.mediator.user.get('id')).child('profile_id').set(data.handle)
          @redirectTo 'home#index'
        else
          console.log '[ERROR] ' + data.handle + ' already exists'
          @view.render()
      @view.dispose()
    @view.render()
