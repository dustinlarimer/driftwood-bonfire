config = require 'config'
Controller = require './base/controller'
#Collection = require 'models/base/collection'

FirebaseCollection = require 'models/base/firebase-collection'
Profile = require 'models/profile'

ProfileView = require 'views/profile/profile-view'
ProfileLatestView = require 'views/profile/profile-latest-view'
ProfileProjectsView = require 'views/profile/profile-projects-view'
ProfileCollaboratorsView = require 'views/profile/profile-collaborators-view'

#Canvas = require 'models/canvas'

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
              @model?.set snapshot.val()
            else
              console.log 'User does not exist'
        
        check: -> @model.get('handle') is params.handle

  latest: (params, route) ->
    console.log 'ProfilesController#latest', params
    
    #_profiles = new FirebaseCollection [{handle: params.handle}], model: Profile
    #_profiles.firebase = new Backbone.Firebase(config.firebase + '/profiles')
    #@model = _profiles.at(0)
    
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    @profilesRef.child(params.handle).on "value", (snapshot) =>
      if snapshot.val()?
        @model = new Profile snapshot.val()
        @view = new ProfileLatestView model: @model, region: 'content'

  projects: (params, route) ->
    console.log 'ProfilesController#projects', params
    current_profile = Chaplin.mediator.execute 'composer:retrieve', 'profile'
    model = current_profile.model
    @view = new ProfileProjectsView model: model, region: 'content'
    #@compose 'projects', ProfileProjectsView, model: @model, region: 'content'

  collaborators: (params, route) ->
    console.log 'ProfilesController#collaborators', params
    current_profile = Chaplin.mediator.execute 'composer:retrieve', 'profile'
    model = current_profile.model
    @view = new ProfileCollaboratorsView model: model, region: 'content'
    #@compose 'collaborators', ProfileCollaboratorsView, model: @model, region: 'content'
