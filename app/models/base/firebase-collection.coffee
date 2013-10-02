Collection = require 'models/base/collection'
Model = require 'models/base/model'

module.exports = class FirebaseCollection extends Collection
  #_(@prototype).extend Backbone.Firebase.Collection
  model: Model
  
  sort_descending: (key) =>
    @comparator = (model) ->
      return -model.get(key)
    @sort()
  
  comparator: (model) ->
    return -model.id
  
  constructor: (models, options) ->
    
    Collection.apply this, arguments
    if options and options.firebase
      @firebase = options.firebase
    
    switch typeof @firebase
      when 'object', 'string'
        @firebase = new Firebase(@firebase)
      when 'function'
        @firebase = @firebase()
      else
        throw new Error('Invalid Firebase reference created')
    
    @firebase.on 'child_added', _.bind @_childAdded, this #@_childAdded(snap) #_.bind @_childAdded, this
    @firebase.on 'child_moved', _.bind @_childMoved, this #_.bind(@_childMoved, this)
    @firebase.on 'child_changed', _.bind @_childChanged, this #_.bind(@_childChanged, this)
    @firebase.on 'child_removed', _.bind @_childRemoved, this #_.bind(@_childRemoved, this)
    
    _updateModel = (model, options) ->
      @firebase.ref().child(model.id).update model.toJSON()
    
    @listenTo(this, 'change', _updateModel, this);

  sync: ->
    return
  
  fetch: ->
    return

  add: (models, options) ->
    parsed = @_parseModels(models)
    options = (if options then _.clone(options) else {})
    options.success = (if _.isFunction(options.success) then options.success else ->
    )
    i = 0

    while i < parsed.length
      model = parsed[i]
      @firebase.ref().child(model.id).set model, _.bind(options.success, model)
      i++

  remove: (models, options) ->
    parsed = @_parseModels(models)
    options = (if options then _.clone(options) else {})
    options.success = (if _.isFunction(options.success) then options.success else ->
    )
    i = 0

    while i < parsed.length
      model = parsed[i]
      @firebase.ref().child(model.id).set null, _.bind(options.success, model)
      i++

  create: (model, options) ->
    @_log "Create called, aliasing to add. Consider using Collection.add!"
    options = (if options then _.clone(options) else {})
    @_log "Wait option provided to create, ignoring."  if options.wait
    model = Collection::_prepareModel.apply(this, [model, options])
    return false  unless model
    @add [model], options
    model

  _log: (msg) ->
    console.log msg  if console and console.log

  
  # TODO: Options will be ignored for add & remove, document this!
  _parseModels: (models) ->
    ret = []
    models = (if _.isArray(models) then models.slice() else [models])
    i = 0

    while i < models.length
      model = models[i]
      model = model.toJSON()  if model.toJSON and typeof model.toJSON is "function"
      model.id = @firebase.ref().push().name()  unless model.id
      ret.push model
      i++
    ret

  _childAdded: (snap) ->
    model = snap.val()
    model.id = snap.name()  unless model.id
    Collection::add.apply this, [model]

  _childMoved: (snap) ->
    
    # TODO: Investigate: can this occur without the ID changing?
    @_log "_childMoved called with " + snap.val()

  _childChanged: (snap) ->
    model = snap.val()
    model.id = snap.name()  unless model.id
    item = _.find(@models, (child) ->
      child.id is model.id
    )
    
    # TODO: Investigate: what is the right way to handle this case?
    throw new Error("Could not find model with ID " + model.id)  unless item
    diff = _.difference(_.keys(item.attributes), _.keys(model))
    _.each diff, (key) ->
      item.unset key

    item.set model

  _childRemoved: (snap) ->
    model = snap.val()
    model.id = snap.name()  unless model.id
    Collection::remove.apply this, [model]