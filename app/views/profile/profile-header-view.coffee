View = require 'views/base/view'
template = require './templates/profile-header'
utils = require 'lib/utils'

module.exports = class ProfileHeaderView extends View
  autoRender: true
  tagName: 'header'
  template: template
  
  initialize: (data={}) ->
    super
    @subscribeEvent 'loginStatus', @render