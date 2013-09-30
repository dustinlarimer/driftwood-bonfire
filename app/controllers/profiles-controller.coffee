Controller = require './base/controller'
Profile = require 'models/profile'

ProfileView = require 'views/profile/profile-view'

ProfileHeaderView = require 'views/profile/profile-header-view'
ProfileSidebarView = require 'views/profile/profile-sidebar-view'

ProfileLatestView = require 'views/profile/profile-latest-view'
ProfileProjectsView = require 'views/profile/profile-projects-view'
ProfileCollaboratorsView = require 'views/profile/profile-collaborators-view'

module.exports = class ProfilesController extends Controller

  beforeAction: (params, route) ->
    super
    if route.action in ['latest', 'projects', 'collaborators']
      @model = new Profile handle: params.handle
      @compose 'profile', ProfileView, model: @model
      @compose 'profile-header', ProfileHeaderView, region: 'header', model: @model
      @compose 'profile-sidebar', ProfileSidebarView, region: 'sidebar', model: @model, active: route.action

      @profilesRef = Chaplin.mediator.firebase.child('profiles')
      @profilesRef.child(params.handle).once "value", (snapshot) =>
        if snapshot.val()?
          @model.set snapshot.val()
        else
          console.log 'User does not exist'

  initialize: ->
    super
    console.log 'initialize'

  latest: (params, route) ->
    console.log 'ProfilesController#latest', params
    @view = new ProfileLatestView model: @model, region: 'content'
  
  projects: (params, route) ->
    console.log 'ProfilesController#projects', params
    @view = new ProfileProjectsView region: 'content'
    
  collaborators: (params, route) ->
    console.log 'ProfilesController#collaborators', params
    @view = new ProfileCollaboratorsView region: 'content'


