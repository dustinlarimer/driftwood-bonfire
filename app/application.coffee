config = require 'config'
mediator = require 'mediator'
Layout = require 'views/layout'
SessionController = require 'controllers/session-controller'
UsersController = require 'controllers/users-controller'

module.exports = class Application extends Chaplin.Application

  initialize: ->
    super
    #new SessionController
    #new UsersController

  initLayout: (options = {}) ->
    options.title ?= @title
    @layout = new Layout options

  initControllers: ->
    #new SessionController()
    #new UsersController()

  initMediator: ->
    mediator.firebase = new Firebase(config.firebase)
    mediator.user = null
    super