template = require './templates/header-member'
View = require 'views/base/view'

module.exports = class HeaderMemberView extends View
  tagName: 'li'
  template: template
  
  render: ->
    super
    @$('button').tooltip({placement: 'bottom'})