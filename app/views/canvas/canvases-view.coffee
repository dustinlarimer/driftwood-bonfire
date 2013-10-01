CollectionView = require 'views/base/collection-view'
CanvasPreviewView = require 'views/canvas/canvas-preview-view'

module.exports = class CanvasesView extends CollectionView
  itemView: CanvasPreviewView
  tagName: 'ul'