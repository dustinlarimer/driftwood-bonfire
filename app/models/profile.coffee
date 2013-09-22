Model = require 'models/base/model'
Collection = require 'models/base/collection'

module.exports = class Profile extends Model
  idAttribute: 'user_id'