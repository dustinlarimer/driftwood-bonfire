Controller = require './base/controller'
User = require 'models/user'
UserPageView = require 'views/user/user-page-view'

module.exports = class UsersController extends Controller
  show: (params) ->
    @model = new User { handle: params.handle }
    @view = new UserPageView { model: @model, region: 'main' }
    @view.render()
    #@model.fetch().then =>
      #@view.render()
      #@_showRepos()
      #@_showOrganizations()
      #@_initSyncRepos()