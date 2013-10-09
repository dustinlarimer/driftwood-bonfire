mediator = require 'mediator'
template = require './templates/header'
View = require 'views/base/view'

Collection = require 'models/base/collection'
HeaderMembersView = require './header/header-members-view'

module.exports = class HeaderView extends View
  autoRender: true
  className: 'navbar navbar-inverse navbar-fixed-top'
  regions:
    members: '.canvas-members'
  template: template
  listen:
    #'sync model': 'render'
    'change:title model': 'render_title'
    'change:members model': 'render_members'

  initialize: (data={}) ->
    super
    console.log '[-- Header view activated --]', @model
    @delegate 'change', '#canvas-attr-title', @update_canvas
    @delegate 'submit', 'form', -> return false

  update_canvas: (e) ->
    @title = @$('.data-canvas-title').val() or 'Untitled'
    if @title isnt @model.get('title')
      @trigger 'canvas:update', {title: @title}
    @$('.data-canvas-title').blur()
    return false
  
  render_title: =>
    @$('input.data-canvas-title').val(@model.get('title'))
    @render_members()
    
  render_members: =>
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    @members = new Collection null
    _.each(_.toArray(@model.get('members')), (d,i)=>
      @profilesRef.child(d.profile_id).once 'value', (snapshot) =>
        @members.add _.extend snapshot.val(), d
    )
    @subview 'canvas-members', new HeaderMembersView collection: @members, region: 'members'
    
    
    