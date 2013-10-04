Controller = require './base/controller'
CanvasView = require 'views/canvas/canvas-view'

module.exports = class CanvasesController extends Controller
  
  beforeAction: (params, route) ->
    super
    @compose 'canvas', CanvasView
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
    #@model = canvas from 'canvases/:id'
    #@view = new CanvasView {@model}

  edit: (params) ->
    console.log 'CanvasesController#edit', params
    #loadLib '/editor.js', ->
    #  @model = canvas from 'canvases/:id'
    #  @view = new EditorView {@model}