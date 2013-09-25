config = require 'config'
FirebaseModel = require 'models/base/firebase-model'

module.exports = class Profile extends FirebaseModel
  firebase: new Backbone.Firebase(config.firebase + '/profiles')