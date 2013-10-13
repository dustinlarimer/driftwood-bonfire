config = require 'config'
utils = require 'lib/utils'
Controller = require './base/controller'

FirebaseModel = require 'models/base/firebase-model'

Canvas = require 'models/canvas/canvas'
CanvasView = require 'views/canvas/canvas-view'

EditorCanvas = null
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
            date_created: new Date().getTime()
            owner_id: owner.user_id
            title: 'Untitled'
          @canvasesRef.child(canvas.id).set(canvas)
          @canvasesRef.child(canvas.id).child('members').child(owner.user_id).set
            user_id: owner.user_id
            role: 'editor'
            date_joined: new Date().getTime()
            profile_id: owner.profile_id

          @profilesRef.child('canvases').child('canvas_' + canvas.id).transaction ((currentData) =>
              canvas if currentData is null
            ), (error, committed, snapshot) =>
              if error
                console.log error
              else if committed
                @redirectTo 'canvases#edit', snapshot.val()

  show: (params) ->
    console.log 'CanvasesController#show', params
    #@canvasesRef = Chaplin.mediator.firebase.child('canvases')
    #@canvasesRef.child(params.id).once 'value', (snapshot) =>
    #  @model = new Canvas snapshot.val()
    @model = new FirebaseModel null, firebase: config.firebase + '/canvases/' + params.id
    @adjustTitle @model?.get('title')
    @view = new CanvasView {model: @model}

  edit: (params, route) ->
    console.log 'CanvasesController#edit', params, route
    
    unless EditorView?
      console.log '[Loading] /javascripts/editor.js'
      utils.loadLib '/javascripts/editor.js', =>
        EditorView = require 'views/editor/editor-view'
        EditorCanvas = require 'models/editor/editor-canvas'
        @edit(params, route)
    else
      console.log 'EditorController is online'
      @model = new EditorCanvas {id: params.id}, firebase: config.firebase + '/canvases/' + params.id
      @view = new EditorView {model: @model}
      @model.on 'change:title', => @adjustTitle @model?.get('title')
      #@model.on 'all', (d,a) => console.log d, a
