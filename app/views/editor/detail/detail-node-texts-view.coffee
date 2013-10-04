mediator = require 'mediator'
CollectionView = require 'views/base/collection-view'

DetailNodeTextView = require 'views/editor/detail/detail-node-text-view'

module.exports = class DetailNodeTextsView extends CollectionView
  autoRender: true
  animationDuration: 0
  itemView: DetailNodeTextView
  tagName: 'div'