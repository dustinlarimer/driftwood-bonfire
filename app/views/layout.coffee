module.exports = class Layout extends Chaplin.Layout

  ###
  initialize: (options= {}) ->
    super
    @adjustTitle(options.title)
  ###