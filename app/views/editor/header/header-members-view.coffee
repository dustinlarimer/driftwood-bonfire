CollectionView = require 'views/base/collection-view'
template = require './templates/header-members'
HeaderMemberView = require './header-member-view'

module.exports = class HeaderMembersView extends CollectionView
  itemView: HeaderMemberView
  listSelector: '.member-avatar-list'
  template: template
  
  render: ->
    super
    @delegate 'click', '.user-action-invite', @invite_user
  
  invite_user: =>
    @publishEvent '!showInvite', @collection