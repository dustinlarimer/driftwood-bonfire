View = require 'views/base/view'

module.exports = class ProfileMainView extends View
  autoRender: true
  tagName: 'section'
  listen:
    'change model': 'render'