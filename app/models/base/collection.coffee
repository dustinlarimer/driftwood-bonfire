Model = require './model'

module.exports = class Collection extends Chaplin.Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Model
  
  sort_descending: (key) =>
    @comparator = (model) ->
      return -model.get(key)
    @sort()