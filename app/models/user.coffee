config = require 'config'
FirebaseModel = require 'models/base/firebase-model'

module.exports = class User extends FirebaseModel
  firebase: new Backbone.Firebase(config.firebase + '/users')