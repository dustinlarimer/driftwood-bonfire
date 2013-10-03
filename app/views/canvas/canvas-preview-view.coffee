View = require 'views/base/view'
template = require './templates/canvas-preview'

module.exports = class CanvasPreviewView extends View
  className: 'canvas-preview'
  tagName: 'li'
  template: template
  
  # Method 1
  # listen:
  #  'change model': 'render'
  
  initialize: ->
    super
    @subscribeEvent 'loginStatus', @render