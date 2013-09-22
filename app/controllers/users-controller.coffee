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
    @subscribeEvent 'userSessionCreated', @findOrCreateUser

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
          #@createProfile(data)
        else
          console.log 'User#' + newUser.id + ' already exists'
          @loadUser(snapshot.val())
        @newProfile(data) if Chaplin.mediator.user.get('profile') is ''

  loadUser: (data) =>
    console.log 'loadUser'
    Chaplin.mediator.user = new User data
    @publishEvent 'userLoaded'

  newProfile: (data) =>
    console.log 'Let\'s create a profile for User#' + data.id
    newProfile=
      user_id: Chaplin.mediator.user.get('id')
      display_name: data.name
      handle: data.handle
      avatar: data.thumbnail_url
      about: ''
      url: ''
      location: data.location
    @model = new Profile newProfile
    @view = new UserRegistrationView {model: @model, region: 'main'}
    @view.bind 'user:create', @createProfile
    @view.render()
  
  createProfile: (profile) =>
    console.log 'createProfile'
    _profile = _.omit(profile, 'handle')
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

  ###
  findOrCreateProfile: (data) =>
    console.log 'Let\'s create a profile for User#' + data.id
    #@model = {}
    #@model = Chaplin.mediator.user
    newProfile=
      user_id: Chaplin.mediator.user.get('id')
      display_name: data.name
      handle: data.handle
      avatar: data.thumbnail_url
      title: ''
      about: ''
      url: ''
      location: data.location
    console.log newProfile
    
    @profilesRef.child(newProfile.handle).transaction ((currentProfileData) =>
        newProfile if currentProfileData is null
      ), (error, success, snapshot) =>
        if success
          console.log 'Profile created: ' + newProfile.handle
          #@loadUser(newUser)
          #@newProfile(newUser)
        else
          console.log newProfile.handle + ' already exists'
          #@loadUser(snapshot.val())
 
    #console.log @model
    #@view = new UserRegistrationView {model: @model, region: 'main'}
    #@view.bind 'user:create', @createProfile
    #@view.render()
  ###


  ###
  findOrCreateProfile: (data) =>
    console.log 'findOrCreateProfile'
    console.log data
    @profilesRef.child(newProfile.handle).transaction ((currentProfileData) =>
        newProfile if currentProfileData is null
      ), (error, success, snapshot) =>
        if success
          console.log 'Profile created: ' + newProfile.handle
          #@loadUser(newUser)
          #@newProfile(newUser)
        else
          console.log newProfile.handle + ' already exists'
          #@loadUser(snapshot.val())
  ###



  # PUBLIC ROUTES
  # ----------------

  show: (params) ->
    @usersRef.child(params.handle).once "value", (snapshot) =>
      if snapshot.val()?
        console.log 'user exists!'
        console.log snapshot.val()
        # @model = new User { handle: params.handle }
        # @view = new UserPageView { model: @model, region: 'main' }
        # @view.render()
      else
        console.log '#404: this user does not exist'
        # @view = new UserUnavailableView
        # @view.render()

  settings: (params) =>
    console.log 'Settings'



  ###
  lookupUser: (data) =>
    @usersRef.child(data.handle).once "value", (snapshot) =>
      if snapshot.val()?
        @loadUser(data)
      else 
        #@redirectToRoute 'users#newUser', data 
        @newUser(data)
  
  createUser: (data) =>
    console.log 'createUser'
    console.log data
    #newUser = @usersRef.push(data.handle)
    newUserAttributes=
      id: data.id
      name: data.name
      location: data.location
      handle: data.handle
    
    @usersRef.child(newUserAttributes.handle).transaction ((currentUserData) =>
        newUserAttributes if currentUserData is null
      ), (error, success) =>
        unless success
  	      console.log 'User ' + newUserAttributes.handle + ' already exists!'
        else
          console.log 'Successfully created user ' + newUserAttributes.handle

    #newUser.set(newUserAttributes)
    @loadUser(data)
    @redirectToRoute 'home#index'
  
  ###
