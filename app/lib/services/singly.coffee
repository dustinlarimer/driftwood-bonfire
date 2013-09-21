config = require 'config'
ServiceProvider = require './service-provider'
User = require 'models/user'

module.exports = class Singly extends ServiceProvider
  baseUrl: config.singly.singlyURL

  constructor: ->
    super
    @accessToken = localStorage.getItem 'accessToken'
    authCallback = _.bind(@loginHandler, this, @loginHandler)
    #@subscribeEvent 'auth:setToken', @setToken
    @subscribeEvent 'auth:callback:singly', authCallback

  ###
  setToken: (token) =>
    console.log 'Singly#setToken', token
    if token?
      localStorage.setItem 'accessToken', token
    else
      localStorage.clear()
    @accessToken = token
  ###

  load: ->
    @resolve()
    @providers = config.singly.providers
    this

  isLoaded: ->
    true

  ajax: (type, url, data) ->
    console.log 'ajax', url, @accessToken, this
    url = @baseUrl + url
    url += "?access_token=#{@accessToken}" if @accessToken
    $.ajax {url, data, type, dataType: 'json'}

  # Trigger login popup
  triggerLogin: (loginContext) ->
    callback = _.bind(@loginHandler, this, @loginHandler)
    #window.location = URL
    singly_url = config.singly.singlyURL + '/oauth/authenticate' +
      '?client_id=' + config.singly.clientID + 
      '&redirect_uri=' + config.singly.redirectURI + 
      '&service=' + loginContext + 
      '&response_type=token'
    window.location = singly_url
    #console.log URL

  # Callback for the login popup
  loginHandler: (loginContext, response) =>
    if response
      @setToken response.accessToken

      # Publish successful login
      console.log 'login successful!'
      @publishEvent 'loginSuccessful', {provider: this, loginContext}

      # Publish the session
      @getUserData().done(@processUserData)
    else
      @publishEvent 'loginFail', provider: this, loginContext: loginContext

  getUserData: ->
    @ajax 'get', '/profile'

  processUserData: (response) ->
    console.log 'processUserData'
    @publishEvent 'userData', response

  getLoginStatus: (callback = @loginStatusHandler, force = false) ->
    #console.log 'getLoginStatus'
    if @accessToken?
      @getUserData().always(callback)
    else
	    callback

  loginStatusHandler: (response, status) =>
    #console.log 'loginStatusHandler'
    if not response or status is 'error'
      console.log status
      @publishEvent 'logout'
    else
      parsed = User::parse.call(null, response)
      @publishEvent 'serviceProviderSession', _.extend parsed,
        provider: this
        userId: response.id
        accessToken: @accessToken

