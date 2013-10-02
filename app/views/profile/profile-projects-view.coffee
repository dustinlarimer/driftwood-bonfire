View = require './profile-main-view'

module.exports = class ProfileProjectsView extends View
  autoRender: true
  template: require './templates/profile-projects'
  
  initialize: ->
    super
    console.log @model