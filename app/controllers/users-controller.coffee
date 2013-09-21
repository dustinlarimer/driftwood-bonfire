#mediator = require 'mediator'
config = require 'config'
Controller = require './base/controller'
User = require 'models/user'
UserPageView = require 'views/user/user-page-view'

module.exports = class UsersController extends Controller

  initialize: ->
    @usersRef = Chaplin.mediator.firebase.child('users')
    @subscribeEvent 'userSessionCreated', @findOrCreateById
    # @subscribeEvent 'userSessionCreated', @lookupUser

  lookupUser: (data) =>
    console.log 'findUser'
    # @loadUser(data) if user? else @newUser(data)
  
  newUser: (data) =>
    console.log 'newUser'
    # @model = new User { id: data.id, handle: data.handle, name: data.name, location: data.location }
    # @view = new UserRegistrationView { model: @model, region: 'main', autoRender: true }
  
  createUser: (data) =>
    console.log 'createUser'
  
  loadUser: (data) =>
    console.log 'loadUser'
    # 

  findOrCreateById: (data) =>
    newUser=
      id: data.id
      name: data.name
      location: data.location
      handle: data.handle
    
    @usersRef.child(data.handle).transaction ((currentUserData) =>
        data.handle if currentUserData is null
      ), (error, success) =>
        #unless success
  	    #  console.log 'User ' + data.id + ' already exists!'
        #else
        #  console.log 'Successfully created user ' + data.id
    
    Chaplin.mediator.user = new User data
    @publishEvent 'userLoaded'
  
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
