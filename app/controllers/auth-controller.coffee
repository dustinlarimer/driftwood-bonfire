mediator = require 'mediator'
Controller = require 'controllers/base/controller'
LoginView = require 'views/login-view'

module.exports = class AuthController extends Controller

  callback: (params) =>
    _.extend params, _.object window.location.hash
      .slice(1).split('&')
      .map((string) -> string.split('='))
    console.log 'AuthController#callback', params
    if params.firebase?
      mediator.firebase.auth params.firebase, (err, authData) =>
        unless err
          #console.log authData
          localStorage.setItem 'accessToken', params.access_token
          @publishEvent 'auth:setToken', params.access_token
          @redirectToRoute 'home#index'
          window.location = window.location.pathname
        else
          alert "Could not authenticate: " + err.message
          @redirectToRoute 'auth#login'
    else if params.error?
      @redirectToRoute 'auth#login', [params.error]
    else
      @redirectToRoute 'auth#login'

  login: =>
    @publishEvent '!showLogin'

  logout: =>
    localStorage.removeItem 'accessToken'
    #localStorage.clear()
    @publishEvent '!logout'
    @redirectToRoute 'home#index'
    #@publishEvent 'auth:setToken', null
    #window.location = window.location.pathname	