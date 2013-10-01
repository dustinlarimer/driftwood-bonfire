config = require 'config'
utils = require 'lib/utils'
View = require 'views/base/view'
template = require './templates/login'

module.exports = class LoginView extends View
  container: 'body'
  autoRender: true
  template: template

  initialize: (options) ->
    super
    @delegate 'click', 'ul.providers a', @authenticate

  authenticate: (e) =>
    provider = $(e.target).attr('class').substr(5)
    @publishEvent 'login:pickService', provider
    @publishEvent '!login', provider
    false