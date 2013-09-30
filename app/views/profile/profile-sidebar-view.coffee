View = require 'views/base/view'
utils = require 'lib/utils'
template = require './templates/profile-sidebar'

module.exports = class ProfileSidebarView extends View
  autoRender: true
  tagName: 'aside'
  template: template
  
  initialize: (data={}) ->
    super
    @active = data.active

  render: ->
    super
    @$('li.active').removeClass('active')
    @$('li[name=' + @active + ']').addClass('active')
  