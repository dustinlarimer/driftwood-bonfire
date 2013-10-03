config = require 'config'
Controller = require './base/controller'
User = require 'models/user'

Profiles = require 'models/profiles'
Profile = require 'models/profile'

SiteView = require 'views/site-view'
UserSettingsView = require 'views/user/user-settings-view'
UserSetupView = require 'views/user/user-setup-view'

module.exports = class UsersController extends Controller

  beforeAction: (params, route) ->
    super
    @compose 'site', SiteView
    
    if route.action in ['settings']
      return @requireLogin(params, route)

  initialize: ->
    super
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    @subscribeEvent 'userRegistered', @join

  settings: ->
    console.log 'UsersController#settings'
    _username = Chaplin.mediator.current_user.get('profile_id')    
    @profilesRef.child(_username).on "value", (snapshot) =>
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
              @redirectTo 'profiles#latest', [_username]
            else
              alert 'error!' + error.message
  
  join: (params) ->
    console.log 'UsersController#join', params
    if !params.id?
      @redirectTo 'home#index'
      return false
    console.log 'Let\'s create a profile for User#' + params.id + ':'
    
    @model = new Profile {display_name: params.name, handle: params.handle}    
    @view = new UserSetupView {model: @model, region: 'main'}    
    @view.bind 'user:create', (data) =>
      
      _profiles = new Profiles
      
      newProfile = _.pick(params, 'location', 'thumbnail_url', 'url')
      newProfile.display_name = data.display_name
      newProfile.handle = data.handle
      newProfile.user_id = params.id
      _new = new Profile newProfile
      
      _profiles.add _new
      _profiles.sync 'update', _new,
        success: (model, response) =>
          Chaplin.mediator.current_user.save {profile_id: model.handle}
          @counterRef = Chaplin.mediator.firebase.child('_stats')
          @counterRef.child('profiles').transaction ((count) ->
            (count or 0) + 1
            ), (error, committed, snapshot) =>
              if error
                console.log error
          @redirectTo 'home#index'
        error: (model, response) =>
          console.log 'Error! ', model
          @view.render()
      
      ###
      _new.save newProfile,
        success: (model, response) =>
          console.log 'success', response
          Chaplin.mediator.current_user.save {profile_id: response.handle}
          @redirectTo 'home#index'
          #window.location = window.location.pathname
        error: (model, response) ->
          console.log 'error', response
          @view.render()
      ###
      @view.dispose()
    @view.render()
