View = require 'views/base/view'
utils = require 'lib/utils'

module.exports = class ProfileHeaderView extends View
  autoRender: true
  tagName: 'header'
  template: require './templates/profile-header'
  
  initialize: (data={}) ->
    super
    @subscribeEvent 'loginStatus', @render