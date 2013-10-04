mediator = require 'mediator'
template = require './templates/header'
View = require 'views/base/view'

module.exports = class HeaderView extends View
  autoRender: true
  className: 'navbar navbar-inverse navbar-fixed-top'
  template: template
  listen:
    'sync model': 'render'

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