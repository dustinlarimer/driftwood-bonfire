Collection = require 'models/base/collection'
Model = require 'models/base/model'

module.exports = class FirebaseCollection extends Collection
  _(@prototype).extend Backbone.Firebase.Collection
  model: Model
  
  sort_descending: (key) =>
    @comparator = (model) ->
      return -model.get(key)
    @sort()