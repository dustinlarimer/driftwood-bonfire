mediator = require 'mediator'
Canvas = require 'models/canvas/canvas'

module.exports = class EditorCanvas extends Canvas

  create_node: (data) =>
    @firebase.child('artifacts/count').transaction ((count) =>
        (count or 0) + 1
      ), (error, committed, snapshot) =>
        if error
          console.log error
        else if committed
          action = @firebase.child('actions').push()
          action.set
            create: [
              'node':
                id: snapshot.val()
                _new:
                  x: data.x
                  y: data.y
            ]
            user: mediator.current_user.get('id')
            time: new Date().getTime()
          #console.log 'Set new action: ', action.name()

  update_node: (data) =>
    _previous_attributes = _.pick(data.model.attributes, _.keys(data.attributes))
    action = @firebase.child('actions').push()
    action.set
      update: [
        'node':
          id: data.model.get('id')
          _new: data.attributes
          _rev: _previous_attributes
      ]
      user: mediator.current_user.get('id')
      time: new Date().getTime()
      

  ###
  handle_actions: (action, direction) =>
	  dir = '_' + direction
    
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
