SiteView = require 'views/site-view'
#HeaderView = require 'views/header-view'
#Navigation = require 'models/navigation'
#NavigationView = require 'views/navigation-view'

module.exports = class Controller extends Chaplin.Controller
  # Compositions persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    @compose 'site', SiteView
    #@compose 'header', HeaderView
    @compose 'auth', ->
      SessionController = require 'controllers/session-controller'
      #UsersController = require 'controllers/users-controller'
      @controller = new SessionController
      #@users = new UsersController
    @compose 'users', ->
      UsersController = require 'controllers/users-controller'
      @controller = new UsersController

    ###if route.name in ['users#show', 'repos#show', 'topics#show']
      @compose 'navigation', ->
        @model = new Navigation
        @view = new NavigationView {@model}###