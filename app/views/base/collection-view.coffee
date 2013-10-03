View = require './view'

module.exports = class CollectionView extends Chaplin.CollectionView
  animationDuration: 250
  getTemplateFunction: View::getTemplateFunction
