mediator = require 'mediator'
View = require 'views/base/view'
template = require 'views/editor/detail/templates/detail-palette-color'

module.exports = class DetailPaletteColorView extends View
  autoRender: true
  template: template
  tagName: 'li'