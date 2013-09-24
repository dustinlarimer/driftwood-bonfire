PageView = require '../base/view'

module.exports = class UserSettingsView extends PageView
  autoRender: true
  containerMethod: 'html'
  template: require './templates/user-settings'
  
  initialize: ->
    super
    @delegate 'click', 'button', @sendForm
    console.log @model
  
  sendForm: =>
    data=
      display_name: @$('input#display_name').val()
      about: @$('textarea#about').val()
      location: @$('input#location').val()
      url: @$('input#url').val()
    @trigger 'profile:update', data