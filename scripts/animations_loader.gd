extends Node2D
tool

"""
	Store and Load animations data for actors.
"""

var _pth = 'res://resources/animations_data'
var civilian_anims = {
	0:{
		'Idle':preload('res://resources/animations_data/johnny_idle.tres'),
		'Running':preload('res://resources/animations_data/johnny_running.tres'),
		'Attacking':preload('res://resources/animations_data/johnny_attacking.tres'),
		'Scared':preload('res://resources/animations_data/johnny_scared.tres'),
		'Hit':preload('res://resources/animations_data/johnny_hit.tres'),
		'Transforming':preload('res://resources/animations_data/johnny_transforming.tres'),
		'Dead':preload('res://resources/animations_data/johnny_dead.tres')
	},
	
	1:{
		'Idle':preload('res://resources/animations_data/barbara_idle.tres'),
		'Running':preload('res://resources/animations_data/barbara_running.tres'),
		'Scared':preload('res://resources/animations_data/barbara_scared.tres'),
		'Hit':preload('res://resources/animations_data/barbara_hit.tres'),
		'Transforming':preload('res://resources/animations_data/barbara_transforming.tres'),
		'Dead':preload('res://resources/animations_data/barbara_dead.tres')
	},
	
	2:{
		'Idle':preload('res://resources/animations_data/johnny_idle.tres'),
		'Running':preload('res://resources/animations_data/johnny_running2.tres'),
		'Attacking':preload('res://resources/animations_data/johnny_attacking.tres'),
		'Scared':preload('res://resources/animations_data/johnny_scared.tres'),
		'Hit':preload('res://resources/animations_data/johnny_hit.tres'),
		'Transforming':preload('res://resources/animations_data/johnny_transforming.tres'),
		'Dead':preload('res://resources/animations_data/johnny_dead.tres')
	}
}

var zombie_anims = {
	0:{
		'Idle':preload('res://resources/animations_data/jzombie_idle.tres'),
		'Attacking':preload('res://resources/animations_data/jzombie_attacking.tres'),
		'Walking':preload('res://resources/animations_data/jzombie_running.tres'),
		'Dead':preload('res://resources/animations_data/jzombie_dead.tres')
	},
	
	1:{
		'Idle':preload('res://resources/animations_data/bzombie_idle.tres'),
		'Attacking':preload('res://resources/animations_data/bzombie_attacking.tres'),
		'Walking':preload('res://resources/animations_data/bzombie_running.tres'),
		'Dead':preload('res://resources/animations_data/bzombie_dead.tres')
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
		get_node(key).set_sprite_frames(data[id][key])
		get_node(key).play()




