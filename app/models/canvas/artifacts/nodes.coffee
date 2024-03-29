mediator = require 'mediator'
Collection = require 'models/base/collection'
Node = require './node'

module.exports = class Nodes extends Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Node

  initialize: ->
    @url = '/compositions/' + mediator.canvas.id + '/nodes/'
    @fetch()
    @on 'add', @node_created
    #@on 'sync', @poll

  fetch: (options = {}) ->
    @beginSync()
    success = options.success
    options.success = (model, response) =>
      success? model, response
      @finishSync()
    super options

  node_created: (node) =>
    console.log '[pub] node_created'
    @publishEvent 'node_created', node