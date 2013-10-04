config = require 'config'
Controller = require './base/controller'
Profile = require 'models/profile'
ProfileView = require 'views/profile/profile-view'
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
          @profilesRef = Chaplin.mediator.firebase.child('profiles')
          @profilesRef.child(params.handle).on "value", (snapshot) =>
            if snapshot.val()?
              @model?.set snapshot.val()
            else
              console.log 'User does not exist'
        check: -> @model.get('handle') is params.handle

  latest: (params, route) ->
    console.log 'ProfilesController#latest', params
    current_profile = Chaplin.mediator.execute 'composer:retrieve', 'profile'
    @view = new ProfileLatestView model: current_profile.model, region: 'content'

  projects: (params, route) ->
    console.log 'ProfilesController#projects', params
    current_profile = Chaplin.mediator.execute 'composer:retrieve', 'profile'
    @view = new ProfileProjectsView model: current_profile.model, region: 'content'

  collaborators: (params, route) ->
    console.log 'ProfilesController#collaborators', params
    current_profile = Chaplin.mediator.execute 'composer:retrieve', 'profile'
    @view = new ProfileCollaboratorsView model: current_profile.model, region: 'content'
