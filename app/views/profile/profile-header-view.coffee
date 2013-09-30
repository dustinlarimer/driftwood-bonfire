View = require 'views/base/view'

module.exports = class ProfileHeaderView extends View
  autoRender: true
  tagName: 'header'
  template: require './templates/profile-header'
  
  listen:
    'change model': 'render'