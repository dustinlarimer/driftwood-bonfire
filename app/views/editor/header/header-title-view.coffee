template = require './templates/header-title'
View = require 'views/base/view'

module.exports = class HeaderTitleView extends View
  autoRender: true
  template: template
  listen:
    'change:title model': 'render'