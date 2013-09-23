SiteView = require 'views/site-view'

module.exports = class Controller extends Chaplin.Controller

  # Compositions persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    @compose 'site', SiteView
    @compose 'auth', ->
      SessionController = require 'controllers/session-controller'
      @controller = new SessionController
    
    #@compose 'users', ->
    #  UsersController = require 'controllers/users-controller'
    #  @controller = new UsersController