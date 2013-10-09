config = require 'config'
mediator = require 'mediator'
template = require './templates/header'
View = require 'views/base/view'

FirebaseCollection = require 'models/base/firebase-collection'
Collection = require 'models/base/collection'

HeaderTitleView = require './header/header-title-view'
HeaderMembersView = require './header/header-members-view'


module.exports = class HeaderView extends View
  autoRender: true
  className: 'navbar navbar-inverse navbar-fixed-top'
  regions:
    title: '.canvas-title'
    members: '.canvas-members'
  template: template
  listen:
    'change:members model': 'render_members'

  initialize: (data={}) ->
    super
    console.log '[-- Header view activated --]', @model
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    @delegate 'change', '#canvas-attr-title', @update_canvas
    @delegate 'submit', 'form', -> return false

  render: ->
    super
    @subview 'canvas-title', new HeaderTitleView model: @model, region: 'title'
    @render_members() if _.toArray(@model?.get('members')).length > 0

  update_canvas: (e) ->
    @title = @$('.data-canvas-title').val() or 'Untitled'
    if @title isnt @model.get('title')
      @trigger 'canvas:update', {title: @title}
    @$('.data-canvas-title').blur()
    return false

  render_members: =>
    @canvas_id = @model.get('id')
    @user_id = mediator.current_user.get('id')
    @members = new FirebaseCollection null, firebase: config.firebase + '/canvases/' + @canvas_id + '/members'
    @members.sort_descending('online')
    @subview 'canvas-members', new HeaderMembersView collection: @members, region: 'members'
    