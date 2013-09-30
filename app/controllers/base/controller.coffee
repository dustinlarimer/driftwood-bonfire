module.exports = class Controller extends Chaplin.Controller

  beforeAction: (params, route) ->
    super
    @compose 'auth', ->
      SessionController = require 'controllers/session-controller'
      @controller = new SessionController

  requireLogin: (params, route) ->
    if Chaplin.mediator.current_user?
      if !Chaplin.mediator.current_user.get('profile_id')?
        @redirectTo 'users#join', {params, route}
    else
      @redirectTo 'auth#login', {params, route}