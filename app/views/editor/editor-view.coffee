config = require 'config'
mediator = require 'mediator'

#FirebaseCollection = require 'models/base/firebase-collection'
FirebaseModel = require 'models/base/firebase-model'

Nodes = require 'models/editor/artifacts/nodes'
#Links = require 'models/editor/artifacts/links'
#Axes = require 'models/editor/artifacts/axes'

CanvasView         = require 'views/canvas/canvas-view'
HeaderView         = require './header/header-view'
DetailView         = require './detail/detail-view'
ControlsView       = require './controls/controls-view'

ToolPointerView    = require './controls/tool-pointer-view'
ToolNodeView       = require './controls/tool-node-view'
ToolLinkView       = require './controls/tool-link-view'
ToolAxisView       = require './controls/tool-axis-view'
ToolTextView       = require './controls/tool-text-view'
ToolEyedropperView = require './controls/tool-eyedropper-view'

MembersDialogView = require './dialog/members-dialog-view'

module.exports = class EditorView extends CanvasView
  id: 'editor-container'
    
  initialize: ->
    super
    
    @_set_presence()
    ###
    if @model?.get('id')?
      @_set_presence()
    else
      @model.once 'sync', => 
        @_set_presence()
    ###
    
    mediator.canvas.nodes = new Nodes
    #mediator.canvas.links = new Links
    #mediator.canvas.axes = new Axes

    @subscribeEvent '!showInvite', @showMembersView
    
    @delegate 'click', '#tool-pointer',    @activate_pointer
    @delegate 'click', '#tool-node',       @activate_node
    @delegate 'click', '#tool-link',       @activate_link
    @delegate 'click', '#tool-axis',       @activate_axis
    #@delegate 'click', '#tool-text',       @activate_text
    @delegate 'click', '#tool-eyedropper', @activate_eyedropper
    
    @delegate 'click', '#tool-download', @download_svg
    
    key 'v', 'editor', @activate_pointer
    key 'n', 'editor', @activate_node
    key 'l', 'editor', @activate_link
    key 'a', 'editor', @activate_axis
    #key 't', 'editor', @activate_text
    key 'i', 'editor', @activate_eyedropper
    key.setScope('editor')
    
    key.filter = (e) ->
      scope = key.getScope()
      tagName = (e.target || e.srcElement).tagName
      if scope is 'all' or scope is 'editor'
        return !(tagName == 'INPUT' || tagName == 'SELECT' || tagName == 'TEXTAREA')
      else
        return !(tagName == 'SELECT' || tagName == 'TEXTAREA')

    ###
    @subscribeEvent 'node_created', @refresh_preview
    @subscribeEvent 'node_updated', @refresh_preview
    @subscribeEvent 'node_removed', @refresh_preview

    @subscribeEvent 'link_created', @refresh_preview
    @subscribeEvent 'link_updated', @refresh_preview
    @subscribeEvent 'link_removed', @refresh_preview

    @subscribeEvent 'axis_created', @refresh_preview
    @subscribeEvent 'axis_updated', @refresh_preview
    @subscribeEvent 'axis_removed', @refresh_preview
    ###

  render: ->
    super
    console.log 'Rendering EditorView [...]', @model
    mediator.canvas.stage.attr('transform', 'translate(50,50)')
    
    @subview 'header-view', new HeaderView model: @model, region: 'header'
    @subview('header-view').bind 'canvas:update', (data) =>
      @model.set data
    
    @subview 'controls_view', new ControlsView region: 'controls'
    @subview 'tool_view', @toolbar_view = null
    @model.once 'sync', => @activate_pointer()
    
    #@subview 'detail_view', new DetailView model: null, region: 'detail'

  _set_presence: =>
    #@current_status = new FirebaseModel {id: mediator.current_user.get('id')},
    #  firebase: config.firebase + '/canvases/' + @model.get('id') + '/members/' + mediator.current_user.get('id')
    
    @presenceRef = @model.firebase.child('members').child(mediator.current_user.get('id'))
    @connectedRef = mediator.firebase.child('.info/connected')
    @connectedRef.on 'value', (snapshot) =>
      if snapshot.val() is true
        @presenceRef.onDisconnect().update
          online: false
          latest: Firebase.ServerValue.TIMESTAMP
        @presenceRef.update
          online: true
          latest: Firebase.ServerValue.TIMESTAMP
      else
        console.log 'not here yet!'

  _clear_presence: =>
    @presenceRef.update
      online: false
      latest: Firebase.ServerValue.TIMESTAMP

  dispose: ->
    @_clear_presence()
    super
    

  # ----------------------------------
  # TOOLBAR METHODS
  # ----------------------------------

  activate_pointer: =>
    @removeSubview 'tool_view'
    @toolbar_view = new ToolPointerView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    @subview('tool_view').bind 'update:node', (data) =>
      @model.update_node data
    return false

  activate_node: =>
    @removeSubview 'tool_view'
    ###
    mediator.selected_nodes = []
    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null
    mediator.publish 'clear_active'
    ###
    @toolbar_view = new ToolNodeView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    @subview('tool_view').bind 'create:node', (data) =>
      @model.create_node data
    return false

  activate_link: =>
    @removeSubview 'tool_view'
    ###
    mediator.selected_nodes = []
    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null
    mediator.publish 'clear_active'
    ###
    @toolbar_view = new ToolLinkView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_axis: =>
    @removeSubview 'tool_view'
    mediator.selected_nodes = []
    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null
    mediator.publish 'clear_active'
    @toolbar_view = new ToolAxisView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_text: =>
    @removeSubview 'tool_view'
    mediator.selected_nodes = []
    mediator.selected_node = null
    mediator.selected_link = null
    mediator.selected_axis = null
    mediator.publish 'clear_active'
    @toolbar_view = new ToolTextView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false

  activate_eyedropper: =>
    @removeSubview 'tool_view'
    @toolbar_view = new ToolEyedropperView el: $('svg', @el)
    @subview 'tool_view', @toolbar_view
    return false



  download_svg: =>
    mediator.stage.select('g.x').style('opacity', 0)
    mediator.stage.select('g.y').style('opacity', 0)
    
    mediator.publish 'refresh_zoom'
    _wrapper  = $('svg g:eq(0)')[0].getBBox()
    _elements = $('#canvas_elements')[0].getBBox()
    $('svg')
      .attr('height', _wrapper.height)
      .attr('width', _wrapper.width)
    $('svg g:eq(0)').attr('transform', => 
      if _elements.x < 0 then _x = Math.abs(_elements.x) else _x = 0
      if _elements.y < 0 then _y = Math.abs(_elements.y) else _y = 0
      #Max: 2135 x 1435
      if _wrapper.width+_x > 2135
        _scale = (2135-_x/2) / (_wrapper.width+_x)
      else
        _scale = 1
      return 'translate(' + (_x*_scale) + ',' + (_y*_scale) + ') scale(' + _scale + ')'
    )

    html = mediator.outer.node().parentNode.innerHTML
    data = "data:image/svg+xml;base64,"+ btoa(html)
    
    @print_window = window.open() #data
    @print_window.document.write(html)
    @print_window.document.title = mediator.canvas.get('title')
    @print_window.document.close()
    @print_window.focus()
    @print_window.print()
    @print_window.close()
    
    $('svg g:eq(0)').attr('transform', null)
    mediator.publish 'refresh_canvas'
    mediator.stage.select('g.x').transition().ease('linear').style('opacity', 1)
    mediator.stage.select('g.y').transition().ease('linear').style('opacity', 1)


  refresh_preview: =>
    # TEMP #
    return false
    
    
    if @refresh_timeout?
      clearTimeout @refresh_timeout 
      @refresh_timeout = null
    @refresh_timeout = setTimeout @send_source, 2000

  send_source: =>
    #_wrapper = mediator.vis[0][0].getBBox()
    #_square = Math.min(_wrapper.height, _wrapper.width)
    #_longedge = Math.max(_wrapper.height, _wrapper.width)

    serializer = new XMLSerializer()
    _svg = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" height="618" width="1000">'
    _svg += serializer.serializeToString(mediator.defs[0][0])
    _svg += '<rect fill="#ffffff" height="618" width="1000"></rect>'
    _svg += '<g transform="translate(' + '0,-25'  + ')">'
    _.each(mediator.vis[0][0].childNodes, (d,i)->
      _svg += serializer.serializeToString(d)
    )
    _svg += '</g>'
    _svg += '</svg>'

    data=
      source: window.btoa(unescape(encodeURIComponent( _svg )))
      #height: _square
      #width: _square
    @model.save preview_data: data
    console.log '[-Refresh Preview-]'

  showMembersView: (collection) =>
    @subview 'dialog', new MembersDialogView model: @model, region: 'dialog'

