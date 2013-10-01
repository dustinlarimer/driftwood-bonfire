#config = require 'config'
#FirebaseModel = require 'models/base/firebase-model'
Model = require 'models/base/model'

module.exports = class Profile extends Model
  idAttribute: 'handle'
  
  #initialize: ->
  #  super
  #  @firebase = new Backbone.Firebase(config.firebase + '/profiles')