View = require 'views/base/view'
template = require './templates/profile'

ProfileHeaderView = require 'views/profile/profile-header-view'

module.exports = class ProfileView extends View
  autoRender: true
  container: '#app-container'
  id: 'profile-container'
  regions:
    header: '#header-container'
    content: '#content-container'
  template: template
  
  listen:
    'change model': 'render_subviews'
  
  initialize: (data={}) ->
    super
    @route = data.route
    @delegate 'click', '.sidebar-container li > a', @update_tabs

  render: ->
    super
    @update_tabs()
    @render_subviews()
  
  render_subviews: =>
    @subview 'header', new ProfileHeaderView model: @model, region: 'header'

  update_tabs: (e) =>
    @route = @$(e.target).parent().attr('name') if e?
    @$('li.active').removeClass('active')
    @$('li[name=' + @route + ']').addClass('active')