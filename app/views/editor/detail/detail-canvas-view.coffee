mediator = require 'mediator'
template = require 'views/editor/detail/templates/detail-canvas'
View = require 'views/base/view'

module.exports = class DetailCanvasView extends View
  autoRender: true
  template: template
  
  initialize: (data={}) ->
    super