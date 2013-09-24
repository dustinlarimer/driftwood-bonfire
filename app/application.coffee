config = require 'config'
mediator = require 'mediator'
Layout = require 'views/layout'

SessionController = require 'controllers/session-controller'

module.exports = class Application extends Chaplin.Application

  initLayout: (options = {}) ->
    options.title ?= @title
    @layout = new Layout options

  initMediator: ->
    mediator.firebase = new Firebase(config.firebase)
    mediator.user = null
    super