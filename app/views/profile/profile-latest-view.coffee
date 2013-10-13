config = require 'config'
ProjectView = require './profile-main-view'
template = require './templates/profile-latest'

FirebaseCollection = require 'models/base/firebase-collection'
Collection = require 'models/base/collection'
Model = require 'models/base/model'

Canvases = require 'models/canvas/canvases'
Canvas = require 'models/canvas/canvas'
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
    if @model?.get('canvases')?
      
      # METHOD 3
      @canvasesRef = Chaplin.mediator.firebase.child('canvases')
      @collection = new Collection #null #, model: Canvas
      @collection.sort_descending('id')
      @subview 'canvas-collection', new CanvasesView collection: @collection, region: 'grid'
      
      _.each(_.toArray(@model.get('canvases')), (canvas) =>
        @canvasesRef.child(canvas.id).once 'value', (snapshot) =>
          @collection.add new Model snapshot.val()
      )
      
      # METHOD 1
      ###
      @collection = new FirebaseCollection null, model: Canvas, firebase: config.firebase + '/canvases'
      @collection.add _.toArray(@model.get('canvases'))
      @subview 'canvas-collection', new CanvasesView collection: @collection, region: 'grid'
      ###
      
      # METHOD 2
      ###
      @collection = new Canvases _.toArray(@model.get('canvases'))
      @subview 'canvas-collection', new CanvasesView collection: @collection, region: 'grid'
      #@listenTo @collection, 'add', -> console.log 'add'
      #@listenTo @collection, 'reset', -> console.log 'reset'
      #@listenTo @collection, 'all', (data)-> console.log 'all', data
      setInterval(@collection.fetch.bind(@collection), 1000)
      ###