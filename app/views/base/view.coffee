require 'lib/view-helper' # Just load the view helpers, no return value

module.exports = class View extends Chaplin.View
  getTemplateFunction: ->
    @template
