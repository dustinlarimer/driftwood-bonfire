config = require 'config'
Controller = require './base/controller'
User = require 'models/user'
Profile = require 'models/profile'
UserPageView = require 'views/user/user-page-view'
UserRegistrationView = require 'views/user/user-registration-view'

module.exports = class UsersController extends Controller

  initialize: ->
    @usersRef = Chaplin.mediator.firebase.child('users')
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    @subscribeEvent 'userRegistered', @newProfile
    #console.log 'Users Controller is here'

  # PUBLIC ROUTES
  # -------------

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

  settings: (params) =>
    console.log 'Settings'



  # AUTHENTICATION / REGISTRATION ROUTES
  # ------------------------------------
  ###
  findOrCreateUser: (data) =>
    console.log 'findOrCreateUser'
    console.log data
    newUser=            # Grab the attributes you want for this user's record...
      id: data.id       # Singly will always return the same ID
      profile: ''       # data.handle OR user-selected, used to retrieve profile resources via "/:handle" routes

    if data.email?
      newUser.email = data.email

    @usersRef.child(newUser.id).transaction ((currentUserData) =>
        newUser if currentUserData is null
      ), (error, success, snapshot) =>
        if success
          console.log 'Created user ' + newUser.id
          @loadUser(newUser)
          @newProfile(data) if Chaplin.mediator.user.get('profile') is ''
        else
          console.log 'User#' + newUser.id + ' already exists'
          @loadUser(snapshot.val())

  loadUser: (data) =>
    console.log 'loadUser'
    Chaplin.mediator.user = new User data
    @publishEvent 'userLoaded'
  ###

  newProfile: (params) =>
    console.log params
    console.log 'Let\'s create a profile for User#' + params.id
    newProfile=
      user_id: Chaplin.mediator.user.get('id')
      display_name: params.name
      handle: params.handle
      avatar: params.thumbnail_url
      about: ''
      url: ''
      location: params.location
    @model = new Profile newProfile
    @view = new UserRegistrationView {model: @model, region: 'main'}
    @view.bind 'user:create', (data) =>
      @createProfile(data)
      @view.dispose()
    @view.render()
  
  createProfile: (profile) =>
    console.log 'createProfile'
    _profile = _.omit(profile, 'handle')
    _profile.user_id = Chaplin.mediator.user.get('id')
    @profilesRef.child(profile.handle).transaction ((currentProfileData) =>
        _profile if currentProfileData is null
      ), (error, success, snapshot) =>
        if success
          console.log 'Profile created: ' + profile.handle
          @usersRef.child(Chaplin.mediator.user.get('id')).child('profile').set(profile.handle)
          @redirectToRoute 'home#index'
        else
          console.log profile.handle + ' already exists'
          #return to newProfile w/ errors
