View = require 'views/base/view'
template = require './templates/base-dialog'
module.exports = class BaseDialogView extends View
  autoRender: true
  id: 'editor-dialog'
  #container: 'body'
  #containerMethod: 'append'
  #el: 'body'
  template: template
  content:
    title: 'Modal title'
    submit: 'Save changes'
  
  getTemplateData: ->
    content: @content
    #@model.attributes
  
  render: ->
    super
    @$('.modal').modal 'show'
    @delegate 'click', '.btn-primary', @submit
    @delegate 'hidden.bs.modal', '.modal', @dispose
  
  submit: =>
    #console.log 'doing it!'
    @$('.modal').modal 'hide'