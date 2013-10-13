mediator = require 'mediator'

Canvas = require 'models/canvas/canvas'
Nodes = require 'models/editor/artifacts/nodes'
#Links = require 'models/editor/artifacts/links'
#Axes = require 'models/editor/artifacts/axes'

module.exports = class EditorCanvas extends Canvas
  
  initialize: ->
    super
    @nodes = new Nodes

  create_node: (data) =>
    action=
      create: [
        node:
          id: 0
          _new:
            x: data.x
            y: data.y
          _rev:
            x: null
            y: null
      ]
    console.log action
    @handle_actions action, 'new'

  handle_actions: (action, direction) =>
	  dir = '_' + direction # 'new' or 'rev'
	
  	if action.update?
  		_.each(action.update, (d) =>
  			if d['node']? then mediator.nodes.get(d['node'].id)?.set d['node'][dir]
  			if d['canvas']? then @model.set d['canvas'][dir]
  		)
	
  	if action.create? and dir is '_new' or action.remove? and dir is '_rev'
  		_.each(action.create, (d) =>
  			if d['node']? then @nodes.create d['node'][dir]
  		)
	
  	if action.remove? and dir is '_new' or action.create? and dir is '_rev'
  		_.each(action.remove, (d) =>
  			if d['node']? then mediator.nodes.find(d['node'].id)?.remove()
  		)

###

Actions Data Model

{
	create: [
		{ 'node': { 
				id: 5, 
				set: { x: 909, y: 230 }
			}
		}
	],
	user: '01280d21j012j38s2k0821d4j012c',
	time: 123124135
}

{
	remove: [
		{ 'node': { 
				id: 5, 
				rev: { x: 909, y: 230 }
			}
		}
	],
	user: '01280d21j012j38s2k0821d4j012c',
	time: 123124135
}

{
	update: [
		{ 'node': { 
				id: 5, 
				set: { x: 909, y: 230 }, 
				rev: { x: 220, y: 322 }
			}
		},
		{ 'node': { 
				id: 2, 
				set: { x: 750, y: 120 }, 
				rev: { x: 120, y: 900 }
			}
		}
	],
	user: '01280d21j012j38s2k0821d4j012c',
	time: 123124135
}

{update:[{'node':{id:5,set:{x:909,y:230},rev:{x:220,y:322}}}],user:'01280d21j012j38s2k0821d4j012c',time:123124135}
{create:[{'node':{id:5,set:{x:909,y:230}}}],user:'01280d21j012j38s2k0821d4j012c',time:123124135}
{remove:[{'node':{id:5,rev:{x:909,y:230}}}],user:'01280d21j012j38s2k0821d4j012c',time:123124135}


{
	update: [
		{ 'canvas': {
				set: { title: 'This is my new jam!' }, 
				rev: { title: 'Untitled' }
			}
		}
	],
	user: '01280d21j012j38s2k0821d4j012c',
	time: 123124135
}

{update:[{'canvas':{set:{title:'This is my new jam!'},rev:{title:'Untitled'}}}],user:'01280d21j012j38s2k0821d4j012c',time:123124135}

Actions DO cover: (things on the stage)
  Canvas attributes
  Compositional elements'
    Node attributes + application of uploaded media
    Link attributes
    Axis attributes
  Layer sorting

Actions DON'T cover: (things in the sidebar)
  Palettes
  Themes (can be cloned, reused and permanently deleted)
    Node patterns
    Link patterns
    Axis patterns
  Presence of uploaded media (only the application)



###
