config = require 'config'
utils = require 'lib/utils'
Controller = require './base/controller'

FirebaseModel = require 'models/base/firebase-model'
Canvas = require 'models/canvas'

CanvasView = require 'views/canvas/canvas-view'
EditorView = null

module.exports = class CanvasesController extends Controller
  
  beforeAction: (params, route) ->
    super
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
    @model = new FirebaseModel null, firebase: config.firebase + '/canvases/' + params.id
    @view = new CanvasView {model: @model} #, region: 'main'

    #@model = new Canvas
    #@canvasesRef = Chaplin.mediator.firebase.child('canvases')
    #@canvasesRef.child(params.id).once 'value', (snapshot) =>
    #  @model.set snapshot.val()
      #@adjustTitle @model?.get('title') or 'Untitled'
      #@compose 'canvas', =>
      #@view = new CanvasView {model: @model} #, region: 'main'
      #@compose 'canvas', CanvasView, {model: @model}

  edit: (params) ->
    console.log 'CanvasesController#edit', params
    
    unless EditorView?
      console.log '[Loading] /javascripts/editor.js'
      utils.loadLib '/javascripts/editor.js', =>
        EditorView = require 'views/editor/editor-view'
        @edit(params)
    else
      console.log 'EditorController is online'
      @model = new FirebaseModel null, firebase: config.firebase + '/canvases/' + params.id
      @view = new EditorView {model: @model}
      
      if @model.get('id')?
        @view.render()
      else
        @model.once 'sync', => @view.render()

      @model.on 'change:title', => @adjustTitle @model?.get('title')
      @model.on 'all', (d,a) => console.log d, a
