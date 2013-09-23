config = require 'config'
Controller = require 'controllers/base/controller'
User = require 'models/user'
Singly = require 'lib/services/singly'
LoginView = require 'views/login-view'

module.exports = class SessionController extends Controller
  # Service provider instances as static properties
  # This just hardcoded here to avoid async loading of service providers.
  # In the end you might want to do this.
  @serviceProviders = {
    singly: new Singly()
    # facebook: new Facebook()
  }
  #@serviceProviders = config.singly.providers

  # Was the login status already determined?
  loginStatusDetermined: false

  # This controller governs the LoginView
  loginView: null

  # Current service provider
  serviceProviderName: null

  initialize: ->
    
    # Firebase References
    @usersRef = Chaplin.mediator.firebase.child('users')
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    
    # Login flow events
    @subscribeEvent 'serviceProviderSession', @serviceProviderSession

    # Handle login
    @subscribeEvent 'logout', @logout
    #@subscribeEvent 'userData', @userData

    # Handler events which trigger an action
    @subscribeEvent 'setAccessToken', @setAccessToken

    # Show the login dialog
    @subscribeEvent '!showLogin', @showLoginView
    # Try to login with a service provider
    @subscribeEvent '!login', @triggerLogin
    # Initiate logout
    @subscribeEvent '!logout', @triggerLogout

    # Session User Loaded
    @subscribeEvent 'userLoaded', @publishLogin

    # Determine the logged-in state
    @getSession()


  setAccessToken: (access_token) =>
    localStorage.setItem 'accessToken', access_token
  
  removeAccessToken: =>
    localStorage.removeItem 'accessToken'

  # Load the libraries of all service providers
  loadServiceProviders: ->
    for name, serviceProvider of SessionController.serviceProviders
      serviceProvider.load()

  ### Instantiate the user with the given data
  createUser: (userData) ->
    Chaplin.mediator.user = new User userData
  ###

  # Try to get an existing session from one of the login providers
  getSession: ->
    @loadServiceProviders()
    for name, serviceProvider of SessionController.serviceProviders
      serviceProvider.done serviceProvider.getLoginStatus

  # Handler for the global !showLogin event
  showLoginView: ->
    return if @loginView
    @loadServiceProviders()
    @loginView = new LoginView region: 'main', serviceProviders: SessionController.serviceProviders

  # Handler for the global !login event
  # Delegate the login to the selected service provider
  triggerLogin: (serviceProviderName) =>
    #serviceProvider = SessionController.serviceProviders.singly
    ### Publish an event in case the provider library could not be loaded
    unless serviceProvider.isLoaded()
      @publishEvent 'serviceProviderMissing', serviceProviderName
      return
    ###

    # Publish a global loginAttempt event
    @publishEvent 'loginAttempt', serviceProviderName

    # Delegate to service provider
    SessionController.serviceProviders.singly.triggerLogin(serviceProviderName)

  # Handler for the global serviceProviderSession event
  serviceProviderSession: (session) =>
    # Save the session provider used for login
    @serviceProviderName = session.provider.name

    # Hide the login view
    #@disposeLoginView()

    # Transform session into user attributes and create a user
    session.id = session.userId
    delete session.userId
    
    @findOrCreateUser session


  findOrCreateUser: (data) =>
    console.log 'findOrCreateUser:'
    newUser=        # Grab the attributes you want for this user's record...
      id: data.id   # Singly will always return the same ID
      profile: ''   # data.handle OR user-selected, used to retrieve profile resources via "/:handle" routes

    if data.email?
      newUser.email = data.email

    @usersRef.child(newUser.id).transaction ((currentUserData) =>
        newUser if currentUserData is null
      ), (error, success, snapshot) =>
        if success
          console.log 'Created user ' + newUser.id
          @loadUser(newUser)
          @publishEvent 'userRegistered', data #if Chaplin.mediator.user.get('profile') is ''
        else
          console.log 'User#' + newUser.id + ' already exists'
          @loadUser(snapshot.val())

  loadUser: (data) =>
    console.log 'loadUser()'
    Chaplin.mediator.user = new User data
    @publishLogin()


  # Publish an event to notify all application components of the login
  publishLogin: ->
    @loginStatusDetermined = true

    # Publish a global login event passing the user
    @publishEvent 'login', Chaplin.mediator.user
    @publishEvent 'loginStatus', true


  # Logout
  # ------

  # Handler for the global !logout event
  triggerLogout: ->
    # Just publish a logout event for now
    @publishEvent 'logout'

  # Handler for the global logout event
  logout: =>
    @removeAccessToken()
    @loginStatusDetermined = true
    @disposeUser()

    # Discard the login info
    @serviceProviderName = null

    # Show the login view again
    # @showLoginView()

    @publishEvent 'loginStatus', false


  # Handler for the global userData event
  # -------------------------------------
  ###
  userData: (data) ->
    Chaplin.mediator.user.set data
  ###
  
  # Disposal
  # --------

  disposeLoginView: ->
    return unless @loginView
    @loginView.dispose()
    @loginView = null

  disposeUser: ->
    return unless Chaplin.mediator.user
    # Dispose the user model
    Chaplin.mediator.user.dispose()
    # Nullify property on the mediator
    Chaplin.mediator.user = null