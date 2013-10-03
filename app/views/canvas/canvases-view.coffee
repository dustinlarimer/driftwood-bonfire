CollectionView = require 'views/base/collection-view'
CanvasPreviewView = require 'views/canvas/canvas-preview-view'

module.exports = class CanvasesView extends CollectionView
  autoRender: true
  itemView: CanvasPreviewView
  tagName: 'ul'
  #listen:
  #  'change collection': 'render'