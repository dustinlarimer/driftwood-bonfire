PageView = require '../base/view'

module.exports = class UserPageView extends PageView
  template: require './templates/user-registration'
  
  initialize: ->
    super
    @delegate 'click', 'button', @sendForm
  
  sendForm: =>
    data=
      #user_id: @model.get('user_id')
      name: @$('input#name').val()
      handle: @$('input#handle').val()
      about: @$('textarea#about').val()
      location: @$('input#location').val()
      url: @$('input#url').val()
    @trigger 'user:create', data