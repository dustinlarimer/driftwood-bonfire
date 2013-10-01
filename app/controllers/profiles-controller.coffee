Controller = require './base/controller'
Profile = require 'models/profile'

ProfileView = require 'views/profile/profile-view'
ProfileHeaderView = require 'views/profile/profile-header-view'

ProfileLatestView = require 'views/profile/profile-latest-view'
ProfileProjectsView = require 'views/profile/profile-projects-view'
ProfileCollaboratorsView = require 'views/profile/profile-collaborators-view'

module.exports = class ProfilesController extends Controller

  beforeAction: (params, route) ->
    super
    if route.action in ['latest', 'projects', 'collaborators']
      @compose 'profile',
        compose: ->
          @model = new Profile {handle: params.handle}
          @view = new ProfileView {model: @model, route: route.action}          
          #@model.fetch()
          @profilesRef = Chaplin.mediator.firebase.child('profiles')
          @profilesRef.child(params.handle).once "value", (snapshot) =>
            if snapshot.val()?
              @model.set snapshot.val()
            else
              console.log 'User does not exist'
          
          check: -> @model.get('handle') is params.handle

  latest: (params, route) ->
    console.log 'ProfilesController#latest', params
    @view = new ProfileLatestView region: 'content'
  
  projects: (params, route) ->
    console.log 'ProfilesController#projects', params
    @view = new ProfileProjectsView region: 'content'
    
  collaborators: (params, route) ->
    console.log 'ProfilesController#collaborators', params
    @view = new ProfileCollaboratorsView region: 'content'


