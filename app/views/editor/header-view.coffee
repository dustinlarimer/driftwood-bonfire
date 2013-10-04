mediator = require 'mediator'
template = require './templates/header'
View = require 'views/base/view'

module.exports = class HeaderView extends View
  autoRender: true
  className: 'navbar navbar-inverse navbar-fixed-top'
  template: template

  initialize: (data={}) ->
    super
    console.log '[-- Header view activated --]', @model
    @delegate 'change', '#canvas-attr-title', @update_canvas
    @delegate 'submit', 'form', @update_canvas

  update_canvas: ->
    _title = @$('#canvas-attr-title').val() or 'Untitled'
    @$('#canvas-attr-title').val(_title) if _title is 'Untitled'
    @$('#canvas-attr-title').blur()
    @trigger 'canvas:update', {title: _title}
    return false