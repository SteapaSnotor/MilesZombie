extends Node2D
tool

"""
	Store and Load animations data for actors.
"""

var _pth = 'res://resources/animations_data'
var civilian_anims = {
	0:{
		'Idle':_pth + '/johnny_idle.tres',
		'Running':_pth + '/johnny_running.tres',
		'Attacking':_pth + '/johnny_attacking.tres',
		'Scared':_pth + '/johnny_scared.tres',
		'Hit':_pth + '/johnny_hit.tres',
		'Transforming':_pth + '/johnny_transforming.tres',
		'Dead':_pth + '/johnny_dead.tres'
	},
	
	1:{
		'Idle':_pth + '/barbara_idle.tres',
		'Running':_pth + '/barbara_running.tres',
		'Scared':_pth + '/barbara_scared.tres',
		'Hit':_pth + '/barbara_hit.tres',
		'Transforming':_pth + '/barbara_transforming.tres',
		'Dead':_pth + '/barbara_dead.tres'
	},
	
	2:{
		'Idle':_pth + '/johnny_idle.tres',
		'Running':_pth + '/johnny_running2.tres',
		'Attacking':_pth + '/johnny_attacking.tres',
		'Scared':_pth + '/johnny_scared.tres',
		'Hit':_pth + '/johnny_hit.tres',
		'Transforming':_pth + '/johnny_transforming.tres',
		'Dead':_pth + '/johnny_dead.tres'
	}
}

var zombie_anims = {
	0:{
		'Idle':_pth + '/jzombie_idle.tres',
		'Attacking':_pth + '/jzombie_attacking.tres',
		'Walking':_pth + '/jzombie_running.tres',
		'Dead':_pth + '/jzombie_dead.tres'
	}
}

#initialize
func init(type,id):
	match type:
		'civilian':
			load_animations(civilian_anims,id)
		'zombie':
			load_animations(zombie_anims,id)
		_:
			pass
	
func load_animations(data,id):
	for key in data[id].keys():
		get_node(key).set_sprite_frames(load(data[id][key]))
		get_node(key).play()
	




