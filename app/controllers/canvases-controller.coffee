Controller = require './base/controller'
CanvasView = require 'views/canvas/canvas-view'

module.exports = class CanvasesController extends Controller
  
  beforeAction: (params, route) ->
    super
    @compose 'canvas', CanvasView

    if route.action in ['edit']
      console.log 'Requires authentication'
      return @requireLogin(params, route)

  create: ->
    console.log 'CanvasesController#create'

  show: (params) ->
    console.log 'CanvasesController#show', params

  edit: (params) ->
    console.log 'CanvasesController#edit', params