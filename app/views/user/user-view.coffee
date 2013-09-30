View = require 'views/base/view'

module.exports = class UserView extends View
  container: 'body'
  id: 'profile-container'
  regions:
    header: '#header-container'
    sidebar: '#sidebar-container'
    main: '#main-container'
  template: require './templates/user'
