Model = require 'models/base/model'

module.exports = class Canvas extends Model
  idAttribute: 'id'

###

Actions Data Model

{
	create: [
		{ 'node': { 
				id: 5, 
				new: { x: 909, y: 230 }
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
				old: { x: 909, y: 230 }
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
				new: { x: 909, y: 230 }, 
				old: { x: 220, y: 322 }
			}
		},
		{ 'node': { 
				id: 2, 
				new: { x: 750, y: 120 }, 
				old: { x: 120, y: 900 }
			}
		}
	],
	user: '01280d21j012j38s2k0821d4j012c',
	time: 123124135
}

{update:[{'node':{id:5,new:{x:909,y:230},old:{x:220,y:322}}}],user:'01280d21j012j38s2k0821d4j012c',time:123124135}
{create:[{'node':{id:5,new:{x:909,y:230}}}],user:'01280d21j012j38s2k0821d4j012c',time:123124135}
{remove:[{'node':{id:5,old:{x:909,y:230}}}],user:'01280d21j012j38s2k0821d4j012c',time:123124135}

###


handle_actions: (action, direction) =>
	# direction is 'new' or 'old'
	
	if action.update?
		_.each(update, (d) =>
			if d['node']? then mediator.nodes.get(d['node'].id)?.set d['node'][direction]
		)
	
	if action.create? and direction is 'new' or action.remove? and direction is 'old'
		_.each(create, (d) =>
			if d['node']? then mediator.nodes.create d['node'][direction]
		)
	
	if action.create? and direction is 'old' or action.remove? and direction is 'new'
		_.each(remove, (d) =>
			if d['node']? then mediator.nodes.find(d['node'].id)?.remove()
		)
