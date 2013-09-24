config = require 'config'
Controller = require './base/controller'
User = require 'models/user'
Profile = require 'models/profile'
UserPageView = require 'views/user/user-page-view'
UserSettingsView = require 'views/user/user-settings-view'
UserSetupView = require 'views/user/user-setup-view'

module.exports = class UsersController extends Controller

  beforeAction: (params, route) ->
    super
    if route.action in ['settings']
      @requireLogin(params, route)

  initialize: ->
    super
    @usersRef = Chaplin.mediator.firebase.child('users')
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    @subscribeEvent 'userRegistered', @join
    console.log 'Users Controller is here'


  show: (params) ->
    @profilesRef.child(params.handle).once "value", (snapshot) =>
      if snapshot.val()?
        @model = new Profile snapshot.val()
        @view = new UserPageView { model: @model, region: 'main' }
      else
        console.log 'User does not exist'
        # @view = new UserUnavailableView
        # @view.render()

  settings: ->
    console.log Chaplin.mediator.user
    _username = Chaplin.mediator.user.get('profile_id')
    @profilesRef.child(_username).once "value", (snapshot) =>
      if snapshot.val()?
        @model = new Profile snapshot.val()
        @view = new UserSettingsView { model: @model, region: 'main' }
        @view.bind 'profile:update', (data) =>
          @profilesRef.child(_username).update 
            display_name: data.display_name
            location: data.location
            about: data.about
            url: data.url
          , (error) =>
            unless error?
              @redirectTo 'users#show', [_username]
            else
              alert 'error!' + error.message
  
  join: (params) ->
    if !params.id?
      @redirectTo 'auth#login'
      return false
    console.log 'Let\'s create a profile for User#' + params.id + ':'
    @model = new Profile {display_name: params.name, handle: params.handle}    
    @view = new UserSetupView {model: @model, region: 'main'}
    
    @view.bind 'user:create', (data) =>
      newProfile=
        display_name: data.display_name
        user_id: Chaplin.mediator.user.get('id')
      
      @profilesRef.child(data.handle).transaction ((currentProfileData) =>
        newProfile if currentProfileData is null
      ), (error, success, snapshot) =>
        if success
          console.log '[SUCCESS] Profile created: ' + snapshot.name()
          @usersRef.child(Chaplin.mediator.user.get('id')).child('profile_id').set(snapshot.name())
          @redirectTo 'home#index'
        else
          console.log '[ERROR] ' + data.handle + ' already exists'
          @view.render()
      @view.dispose()
    @view.render()
