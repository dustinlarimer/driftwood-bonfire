config = require 'config'
Collection = require 'models/base/collection'

module.exports = class Profiles extends Collection

  initialize: ->
    super
    @firebase = new Backbone.Firebase(config.firebase + '/profiles')