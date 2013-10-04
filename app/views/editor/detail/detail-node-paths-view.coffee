mediator = require 'mediator'
CollectionView = require 'views/base/collection-view'

DetailNodePathView = require 'views/editor/detail/detail-node-path-view'

module.exports = class DetailNodePathsView extends CollectionView
  autoRender: true
  animationDuration: 0
  itemView: DetailNodePathView
  tagName: 'div'