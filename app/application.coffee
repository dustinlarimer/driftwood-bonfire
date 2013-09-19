config = require 'config'
mediator = require 'mediator'
Layout = require 'views/layout'

module.exports = class Application extends Chaplin.Application

  initialize: ->
    super

  initLayout: (options = {}) ->
    options.title ?= @title
    @layout = new Layout options

  initMediator: ->
    mediator.firebase = new Firebase(config.firebase)
    mediator.user = null
    super