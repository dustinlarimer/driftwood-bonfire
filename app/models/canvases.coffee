config = require 'config'
FirebaseCollection = require 'models/base/collection'

module.exports = class Users extends FirebaseCollection

  initialize: ->
    super
    @firebase = new Backbone.Firebase(config.firebase + '/canvases')
    # Add this on init since no permissions exist before authentication
