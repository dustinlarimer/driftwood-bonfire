config = require 'config'
mediator = require 'mediator'
Layout = require 'views/layout'

module.exports = class Application extends Chaplin.Application

  initLayout: (options = {}) =>
    options.title ?= @title
    options.titleTemplate = _.template("<%= subtitle %> | <%= title %>")
    @layout = new Layout options

  initMediator: ->
    #Firebase.enableLogging(true)
    mediator.firebase = new Firebase(config.firebase)
    mediator.users = null
    mediator.current_user = null
    mediator.canvas = {}
    super