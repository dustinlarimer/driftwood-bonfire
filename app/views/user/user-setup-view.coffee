PageView = require '../base/view'

module.exports = class UserSetupView extends PageView
  template: require './templates/user-setup'
  
  initialize: ->
    super
    @delegate 'click', 'button', @sendForm
    console.log @model
  
  sendForm: =>
    data=
      #user_id: @model.get('user_id')
      display_name: @$('input#display_name').val()
      handle: @$('input#handle').val()
      #about: @$('textarea#about').val()
      #location: @$('input#location').val()
      #url: @$('input#url').val()
    @trigger 'user:create', data