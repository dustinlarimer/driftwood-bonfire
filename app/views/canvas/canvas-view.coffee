mediator = require 'mediator'
template = require './templates/canvas'
View = require 'views/base/view'

Nodes = require 'models/canvas/artifacts/nodes'
#Links = require 'models/canvas/artifacts/links'
#Axes = require 'models/canvas/artifacts/axes'

NodeView = require 'views/canvas/artifacts/node-view'
#LinkView = require 'views/canvas/artifacts/link-view'
#AxisView = require 'views/canvas/artifacts/axis-view'

module.exports = class CanvasView extends View
  autoRender: true
  container: 'body'
  containerMethod: 'html'
  className: 'canvas-container'
  id: 'canvas-container'
  regions:
    header: '.header-container'
    controls: '.controls-container'
    stage: '.stage-container'
    detail: '.detail-container'
    dialog: '.dialog-container'
  template: template

  initialize: ->
    super
    console.log 'Initializing ', @
    
    $(window).on 'resize', @refresh
    key 'command+1', @reset_zoom
    key 'control+1', @reset_zoom
    
    mediator.canvas.nodes = new Nodes
    #mediator.canvas.links = new Links
    #mediator.canvas.axes = new Axes

  dispose: ->
    mediator.canvas = {}
    super
    

  # ----------------------------------
  # FORCE/CANVAS METHODS
  # ----------------------------------

  @viewport=
    height: -> return window.innerHeight
    width: -> return window.innerWidth

  bounds=
    height: @viewport.height()
    width: @viewport.width()
    x: [0, @viewport.width()]
    y: [0, @viewport.height()]

  x = d3.scale.linear()
    .domain([0, bounds.width])
    .range([0, bounds.width])

  y = d3.scale.linear()
    .domain([0, bounds.height])
    .range([0, bounds.height])

  xAxis = d3.svg.axis()
    .scale(x)
    .orient('top')
    .tickPadding(-20)
    .ticks(20)
    .tickSize(-10,-5,0)
    .tickSubdivide(5)

  yAxis = d3.svg.axis()
    .scale(y)
    .orient('left')
    .tickPadding(-12)
    .ticks(10)
    .tickSize(-10,-5,0)
    .tickSubdivide(5)


  force = d3.layout.force()


  # ----------------------------------
  # Initialize Artifacts
  # ----------------------------------

  init_artifacts: ->
    _.each(mediator.canvas.nodes.models, (node,i) => 
      force.nodes().push { id: node.id, x: node.get('x'), y: node.get('y'), opacity: node.get('opacity')/100, rotate: node.get('rotate'), model: node }
    ) #if mediator.nodes?
    @subscribeEvent 'node_created', @add_node
    @subscribeEvent 'node_updated', @update_node
    @subscribeEvent 'node_removed', @remove_node
    @build_nodes()


  # ----------------------------------
  # NODES
  # ----------------------------------

  drag_node_start: (d, i) ->
    mediator.publish 'refresh_canvas'
    d3.event.sourceEvent.stopPropagation()

  drag_node_move: (d, i) ->
    d3.event.sourceEvent.stopPropagation()
    d.rotate = d.model.get('rotate')
    d.x = d3.event.x
    d.y = d3.event.y
    d.px = d.x
    d.py = d.y
    d3.select(@).attr('transform', 'translate('+ d.x + ',' + d.y + ') rotate(' + d.rotate + ')')

  drag_node_end: (d, i) ->
    mediator.publish 'refresh_canvas'

  add_node: (node) ->
    force.nodes().push { id: node.id, x: node.get('x'), y: node.get('y'), opacity: node.get('opacity')/100, rotate: node.get('rotate'), model: node }
    @build_nodes()

  update_node: (node) ->
    _.each(force.nodes(), (d,i)->
      if d.id is node.id
        d.x = node.get('x')
        d.y = node.get('y') 
        d.opacity = node.get('opacity')/100
        d.rotate = node.get('rotate')
        d.px = d.x
        d.py = d.y
    )
    @refresh()

  remove_node: (node_id) ->
    _node = _.findWhere(force.nodes(), {id: node_id})
    _index = force.nodes().indexOf(_node)
    force.nodes().splice(_index,1)
    @refresh()

  build_nodes: ->
  
    node_drag_events = d3.behavior.drag()
      .on('dragstart', @drag_node_start)
      .on('drag', @drag_node_move)
      .on('dragend', @drag_node_end)
  
    mediator.canvas.node = mediator.canvas.vis
      .selectAll('g.nodeGroup')
      .data(force.nodes())
  
    mediator.canvas.node
      .enter()
      .append('svg:g')
      .attr('class', 'nodeGroup')
      .attr('cursor', 'pointer')
      .attr('pointer-events', 'painted')
      .attr('opacity', (d)-> d.model.get('opacity')/100)
      .attr('transform', (d)->
        return 'translate('+ d.x + ',' + d.y + ') rotate(' + d.model.get('rotate') + ')'
      )
      .each((d,i)-> d.view = new NodeView({model: d.model, el: @}))
      .call(node_drag_events)
  
    mediator.canvas.node
      .exit()
      .remove()
  
    @refresh()


  

  # ----------------------------------
  # RENDER VIEW
  # ----------------------------------

  render: ->
    super
    console.log 'Rendering CanvasView [...]'

    @zoom = d3.behavior.zoom()
      .x(x)
      .y(y)
      .scaleExtent([0.5, 5])
      .on('zoom', @canvas_zoom)

    mediator.canvas.outer = d3.select(@$('.stage-container')[0])
      .append('svg:svg')
      .attr('xmlns', 'http://www.w3.org/2000/svg')
      .attr('xmlns:xmlns:xlink', 'http://www.w3.org/1999/xlink')
      .attr('pointer-events', 'all')

    mediator.canvas.defs = mediator.canvas.outer.append('svg:defs')
    
    mediator.canvas.stage = mediator.canvas.outer.append('svg:g')
      .attr('id', 'canvas_wrapper')
      .attr('transform', 'translate(50,50)')
      .call(@zoom)
    
    mediator.canvas.stage.append('svg:rect')
      .attr('id', 'canvas_background')
      .attr('fill', '#fff')
    
    mediator.canvas.stage.append('svg:g')
      .attr('class', 'x axis')
      .attr('visibility', 'hidden')
      .attr('transform', 'translate(0,0)')
      .call(xAxis)
    
    mediator.canvas.stage.append('svg:g')
      .attr('class', 'y axis')
      .attr('visibility', 'hidden')
      .attr('transform', 'translate(0,0)')
      .call(yAxis)
      
    mediator.canvas.stage.append('svg:rect')
      .attr('id', 'canvas_elements_background')
      .attr('fill', 'none')
  
    mediator.canvas.vis = mediator.canvas.stage.append('svg:g')
      .attr('id', 'canvas_elements')

    mediator.canvas.vis_axes = mediator.canvas.vis.append('svg:g')
      .attr('id', 'canvas_axes')

    mediator.canvas.controls = mediator.canvas.stage.append('svg:g')
      .attr('id', 'canvas_controls')

    force
      .charge(0)
      .gravity(0)
      .linkStrength(0)
      .size([bounds.width, bounds.height])

    @subscribeEvent 'refresh_canvas', @refresh
    @subscribeEvent 'refresh_zoom', @reset_zoom

    @init_artifacts()
    #@refresh()
    
    if $('#detail').length is 0
      @canvas_width = @$('#canvas_elements')[0].getBoundingClientRect().width
      @visual_offset = (bounds.width - 940) / 2
      if @canvas_width < bounds.width
        @zoom.scale(1).translate([@visual_offset,0])
        mediator.canvas.vis.attr('transform', 'translate(' + @visual_offset + ',' + 0 + ')')




  # ----------------------------------
  # REFRESH CANVAS
  # ----------------------------------

  refresh: =>

    @editor_offset = (@$('#detail').width()*1.3) or 0
    @canvas_elements = @$('#canvas_elements')[0].getBoundingClientRect()

    bounds.x = @canvas_elements.width + @editor_offset
    bounds.y = Math.max(@canvas_elements.bottom, @canvas_elements.height)
    if @editor_offset > 0
      bounds.height = window.innerHeight
      bounds.width = window.innerWidth
    else
      bounds.height = window.innerHeight
      bounds.width = window.innerWidth
  
    #console.log '⟲ Refreshed Bounds:\n' + JSON.stringify(bounds, null, 4)
  
    @$('svg, #canvas_background, #canvas_elements_background')
      .attr('height', bounds.height)
      .attr('width', bounds.width)
    @$('#detail-wrapper').css('min-height', bounds.height)

    force
      .size([bounds.width, bounds.height])
      .start()
  
    #mediator.stage.select('g.x').call(xAxis)
    #mediator.stage.select('g.y').call(yAxis)

  # ----------------------------------
  # ZOOM CANVAS
  # ----------------------------------

  canvas_zoom: =>
    #console.log d3.event?.translate or [0,0]
    
    mediator.canvas.offset = [d3.event?.translate or [0,0], d3.event?.scale or 1]

    mediator.canvas.vis
      .attr('transform', 'translate(' + (d3.event?.translate or [0,0]) + ') scale(' + (d3.event?.scale or 1) + ')')

    mediator.canvas.controls
      .attr('transform', 'translate(' + (d3.event?.translate or [0,0]) + ') scale(' + (d3.event?.scale or 1) + ')')

    mediator.canvas.stage.select('g.axis.x').call(xAxis)
    mediator.canvas.stage.select('g.axis.y').call(yAxis)
    d3.selectAll('g.axis text').transition().ease('linear').style('opacity', 1)

    if d3.event?.scale > 1
      mediator.canvas.stage.attr('class', 'zoom_in')
    else if d3.event?.scale < 1
      mediator.canvas.stage.attr('class', 'zoom_out')
    else
      mediator.canvas.stage.attr('class', null)

  reset_zoom: =>
    @zoom.scale(1).translate([0,0])
    @canvas_zoom()
    return false



  

###

  force.on 'tick', ->
    if mediator.node?
      mediator.node
        #.transition()
        #.ease('linear')
        .attr('opacity', (d)-> d.opacity)
        .attr('transform', (d)->
          return 'translate('+ d.x + ',' + d.y + ') rotate(' + d.rotate + ')'
        )

    if mediator.link?
      mediator.link
        #.attr('opacity', (d)-> d.opacity)
        .selectAll('path.baseline, path.tickline')
        #.transition()
        #.ease('linear')
        #.duration(100)
        .attr('d', (d)->
          _target = _.findWhere(force.nodes(), {id: d.get('target')})
          _source = _.findWhere(force.nodes(), {id: d.get('source')})
          _interpolation = d.get('interpolation')
          if _target? and _source?
            _def = mediator.defs.select('path#link_' + d.id + '_path') #.transition().ease('linear').duration(100)
            _endpoints = d.get('endpoints')
            _midpoints = d.get('midpoints')
            data = []
            data.push { x: _source.x + _endpoints[0][0], y: _source.y + _endpoints[0][1] }
            _.each(_midpoints, (m,i)->
              data.push { x: _midpoints[i][0], y: _midpoints[i][1] }
            )
            data.push { x: _target.x + _endpoints[1][0], y: _target.y + _endpoints[1][1] }
            line = d3.svg.line()
              .x((d)-> return d.x)
              .y((d)-> return d.y)
              .interpolate(_interpolation)(data)
            _def.attr('d', line)
            return line
          else
            return 'M 0,0'
        )
      mediator.link
        .selectAll('.textpath')
          .attr('xlink:href', (d)-> '#link_' + d.id + '_path')



  # ----------------------------------
  # Initialize Artifacts
  # ----------------------------------

  init_artifacts: ->
    #_.each(mediator.nodes.models, (node,i) => 
    #  force.nodes().push { id: node.id, x: node.get('x'), y: node.get('y'), opacity: node.get('opacity')/100, rotate: node.get('rotate'), model: node }
    #) #if mediator.nodes?
    #@subscribeEvent 'node_created', @add_node
    #@subscribeEvent 'node_updated', @update_node
    #@subscribeEvent 'node_removed', @remove_node
    #@build_nodes()
  
    _.each(mediator.links.models, (link,i) => 
      _source = _.where(force.nodes(), {id: link.get('source')})[0]
      _target = _.where(force.nodes(), {id: link.get('target')})[0]
      force.links().push { id: link.id, source: _source, target: _target, opacity: link.get('stroke_opacity')/100, model: link }
    ) #if mediator.links?
    @subscribeEvent 'link_created', @add_link
    @subscribeEvent 'link_updated', @update_link
    @subscribeEvent 'link_removed', @remove_link
    @build_links()

    @subscribeEvent 'axis_created', @add_axis
    @subscribeEvent 'axis_updated', @update_axis
    @subscribeEvent 'axis_removed', @remove_axis
    @build_axes()







  # ----------------------------------
  # LINKS
  # ----------------------------------

  add_link: (link) ->
    _source = _.where(force.nodes(), {id: link.get('source')})[0]
    _target = _.where(force.nodes(), {id: link.get('target')})[0]
    force.links().push { id: link.id, source: _source, target: _target, model: link }
    #opacity: link.get('stroke_opacity')/100, 
    @build_links()

  update_link: (link) ->
    #_.each(force.links(), (d,i)->
    #  if d.id is link.id
    #    d.opacity = link.get('stroke_opacity')/100
    #)
    @refresh()

  remove_link: (link_id) ->
    _link = _.findWhere(force.links(), {id: link_id})
    _index = force.links().indexOf(_link)
    force.links().splice(_index,1)
    @refresh()

  build_links: ->
    #force.stop()
    mediator.link = mediator.vis
      .selectAll('g.linkGroup')
      .data(force.links())
  
    mediator.link
      .enter()
      .insert('svg:g', 'g.nodeGroup')
      .attr('class', 'linkGroup')
      #.attr('pointer-events', 'stroke')
      #.attr('opacity', (d)-> d.model.get('stroke_opacity')/100)
      .each((d,i)-> d.view = new LinkView({model: d.model, el: @, source: d.source, target: d.target}))
  
    mediator.link
      .exit()
      .remove()
  
    @refresh()



  # ----------------------------------
  # AXES
  # ----------------------------------

  add_axis: (axis) =>
    @build_axes()

  update_axis: (axis) =>
    @build_axes()

  remove_axis: (axis_id) =>
    @refresh()

  build_axes: =>

    mediator.axis = mediator.vis_axes
      .selectAll('g.axisGroup')
      .data(mediator.axes.models)

    mediator.axis
      .enter()
      .append('svg:g')
      .attr('class', 'axisGroup')
      .attr('pointer-events', 'all')
      .attr('transform', (d)->
        return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')'
      )
      .each((d,i)-> d.view = new AxisView({model: d, el: @}))

    mediator.axis
      .attr('transform', (d)->
        return 'translate('+ d.get('x') + ',' + d.get('y') + ') rotate(' + d.get('rotate') + ')'
      )
  
    mediator.axis
      .exit()
      .remove()
  
    @refresh()



  
###