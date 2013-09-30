View = require 'views/base/view'

module.exports = class CanvasView extends View
  container: 'body'
  id: 'canvas-container'
  regions:
    header: '#header-container'
    controls: '#controls-container'
    detail: '#detail-container'
    stage: '#stage-container'
  template: require './templates/canvas'
