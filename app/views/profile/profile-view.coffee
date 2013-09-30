View = require 'views/base/view'

module.exports = class ProfileView extends View
  autoRender: true
  container: 'body'
  id: 'profile-container'
  regions:
    header: '#header-container'
    sidebar: '#sidebar-container'
    content: '#content-container'
  template: require './templates/profile'