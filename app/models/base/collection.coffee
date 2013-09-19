Model = require './model'
#Chaplin = require 'chaplin'

module.exports = class Collection extends Chaplin.Collection
  _.extend @prototype, Chaplin.SyncMachine

  model: Model

  initialize: (models, options) ->
    @url = options.url if options?.url?
    super

  urlPath: ->
    "
/users/#{@urlParams.login}
/repos/#{@urlParams.repoName}
/topics/#{@urlParams.topicNumber}
/posts/"