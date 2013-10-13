config = require 'config'
Collection = require 'models/base/collection'
Canvas = require 'models/canvas/canvas'

module.exports = class Users extends Collection
  model: Canvas
  
  initialize: ->
    super
    @firebase = new Backbone.Firebase(config.firebase + '/canvases')
    # Add this on init since no permissions exist before authentication

  comparator: (model) ->
    return -model.id