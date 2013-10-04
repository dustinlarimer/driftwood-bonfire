utils = require 'lib/utils'
Controller = require './base/controller'

Canvas = require 'models/canvas'
CanvasView = require 'views/canvas/canvas-view'

module.exports = class CanvasesController extends Controller
  
  beforeAction: (params, route) ->
    super
    #@compose 'canvas', CanvasView
    if route.action in ['create', 'edit']
      return @requireLogin(params, route)

  create: ->
    console.log 'CanvasesController#create'  
    owner=
      user_id: Chaplin.mediator.current_user.get('id')
      profile_id: Chaplin.mediator.current_user.get('profile_id')
      
    @canvasesRef = Chaplin.mediator.firebase.child('canvases')
    @profilesRef = Chaplin.mediator.firebase.child('profiles').child(owner.profile_id)
    
    @counterRef = Chaplin.mediator.firebase.child('_stats')
    @counterRef.child('canvases').transaction ((count) =>
        (count or 0) + 1
      ), (error, committed, snapshot) =>
        if error
          console.log error
        else if committed
          canvas=
            id: snapshot.val()
              
          @canvasesRef.child(canvas.id).set({id: canvas.id, owner_id: owner.user_id})
          @profilesRef.child('canvases').child('canvas_' + canvas.id).transaction ((currentData) =>
              canvas if currentData is null
            ), (error, committed, snapshot) =>
              if error
                console.log error
              else if committed
                @redirectTo 'canvases#edit', snapshot.val()

  show: (params) ->
    console.log 'CanvasesController#show', params
    @model = new Canvas
    @canvasesRef = Chaplin.mediator.firebase.child('canvases')
    @canvasesRef.child(params.id).on 'value', (snapshot) =>
      @model.set snapshot.val()
    @view = new CanvasView {@model}
    #@compose 'canvas', CanvasView, {model: @model}

  edit: (params) ->
    console.log 'CanvasesController#edit', params
    utils.loadLib '/javascripts/editor.js', ->
      EditorView = require 'views/editor/editor-view'
      console.log 'EditorController is online'
      @model = new Canvas
      @canvasesRef = Chaplin.mediator.firebase.child('canvases')
      @canvasesRef.child(params.id).on 'value', (snapshot) =>
        @model.set snapshot.val()
      @view = new EditorView {@model}
      #@compose 'editor', EditorView, {model: @model}
      
