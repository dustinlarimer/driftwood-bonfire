mediator = require 'mediator'
Model = require 'models/base/model'
Collection = require 'models/base/collection'

module.exports = class User extends Model
  urlKey: 'handle'

  #initialize: (data) ->
  #  console.log 'User model created'
  #  console.log data

  urlPath: ->
    '/users/'

  parse: (response) ->
    return @previousAttributes unless response?
    options = {model: User}
    ###
    if response.organizations?
      organizations = new Collection response.organizations, options
      _.extend response, {organizations}
    if response.owners?
      owners = new Collection response.owners, options
      _.extend response, {owners}
    ####
    response

  # Ideally, there should be a special model field for this.
  isAdmin: ->
    @get('handle') is 'larimer' or 'dustinlarimer'