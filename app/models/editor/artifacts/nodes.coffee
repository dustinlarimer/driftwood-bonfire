mediator = require 'mediator'
PublicNodes = require 'models/canvas/artifacts/nodes'
Node = require './node'

module.exports = class Nodes extends PublicNodes
  _.extend @prototype, Chaplin.SyncMachine
  model: Node

  initialize: ->
    @on 'add', @node_created

  node_created: (node) =>
    console.log '[node_created]', node
    @publishEvent 'node_created', node