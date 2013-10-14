mediator = require 'mediator'
template = require './templates/controls'
View = require 'views/base/view'

module.exports = class ControlsView extends View
  autoRender: true
  id: 'toolbar'
  template: template
  
  render: ->
    super
    @$('button').tooltip({placement: 'right'})