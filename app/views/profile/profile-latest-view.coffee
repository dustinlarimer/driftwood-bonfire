config = require 'config'
ProjectView = require './profile-main-view'
template = require './templates/profile-latest'

FirebaseCollection = require 'models/base/firebase-collection'
Canvas = require 'models/canvas'
CanvasesView = require 'views/canvas/canvases-view'


module.exports = class ProfileLatestView extends ProjectView
  autoRender: true
  containerMethod: 'html'
  regions:
    grid: '.grid'
  template: template
  listen:
    'sync model': 'render'
  
  render: ->
    super
    console.log 'rendering subview'
    if @model?.get('canvases')?
      @collection = new FirebaseCollection _.toArray(@model.get('canvases')), model: Canvas
      @collection.firebase = new Backbone.Firebase(config.firebase + '/canvases')
      @collection.sort_descending('id')
      @subview 'canvas-collection', new CanvasesView collection: @collection, region: 'grid'    