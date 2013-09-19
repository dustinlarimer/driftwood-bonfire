PageView = require '../base/view'

module.exports = class UserPageView extends PageView
  #regions:
  #  'repos': '.user-repo-list-container'
  #  'sync-repos': '.user-repo-sync-container'
  #  'relations': '.user-relations'
  template: require './templates/user-page'

  #getNavigationData: ->
  #  gravatar_id: @model.get('gravatar_id'),
  #  user_login: @model.get('login')