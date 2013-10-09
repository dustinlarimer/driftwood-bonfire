Model = require 'models/base/model'

module.exports = class FirebaseModel extends Model
  #_(@prototype).extend Backbone.Firebase.Model
  
  save: ->
    @_log "Save called on a Firebase model, ignoring."
  
  destroy: (options) ->
    # TODO: Fix naive success callback. Add error callback.
    @firebase.ref().set null, @_log
    @trigger "destroy", this, @collection, options
    options.success this, null, options  if options.success
  
  constructor: (model, options) ->  
    # Apply parent constructor (this will also call initialize).
    Model.apply this, arguments
    @firebase = options.firebase  if options and options.firebase
    switch typeof @firebase
      when "object", "string"
        @firebase = new Firebase(@firebase)
      when "function"
        @firebase = @firebase()
      else
        throw new Error("Invalid firebase reference created")
    
    # Add handlers for remote events.
    @firebase.on "value", _.bind @_modelChanged, this
    @_listenLocalChange true
  
  
  _listenLocalChange: (state) ->
    if state
      @on "change", @_updateModel, this
    else
      @off "change", @_updateModel, this

  _updateModel: (model, options) ->  
    # Find the deleted keys and set their values to null
    # so Firebase properly deletes them.
    modelObj = model.toJSON()
    _.each model.changed, (value, key) ->
      if typeof value is "undefined" or value is null
        if key is "id"
          delete modelObj[key]
        else
          modelObj[key] = null

    @firebase.ref().update modelObj, @_log  if _.size(modelObj)

  _modelChanged: (snap) ->
    # Make sure this little fucker is still around.
    return if @disposed
    
    # Unset attributes that have been deleted from the server
    # by comparing the keys that have been removed.
    newModel = snap.val()
    if typeof newModel is "object" and newModel isnt null
      diff = _.difference(_.keys(@attributes), _.keys(newModel))
      _this = this
      _.each diff, (key) ->
        _this.unset key

    @_listenLocalChange false
    @set newModel
    @trigger "sync", this, null, null
    @_listenLocalChange true

  _log: (msg) ->
    return  if typeof msg is "undefined" or msg is null
    console.log msg  if console and console.log