config = require 'config'
FirebaseModel = require 'models/base/firebase-model'

module.exports = class Profile extends FirebaseModel
  idAttribute: 'handle'
  
  initialize: ->
    super
    @firebase = new Backbone.Firebase(config.firebase + '/profiles')