extends Node2D
tool

"""
	Load animations data for actors.
"""

var _pth = 'res://resources/animations_data'
var civilian_anims = {
	0:{
		'Idle':_pth + '/johnny_idle.tres',
		'Running':_pth + '/johnny_running.tres',
		'Attacking':_pth + '/johnny_attacking.tres',
		'Scared':_pth + '/johnny_scared.tres',
		'Hit':_pth + '/johnny_hit.tres'
	},
	
	1:{
		'Idle':_pth + '/barbara_idle.tres',
		'Running':_pth + '/barbara_running.tres',
		'Scared':_pth + '/barbara_scared.tres',
		'Hit':_pth + '/barbara_hit.tres'
	}
}

#initialize
func init(type,id):
	match type:
		'civilian':
			load_animations(civilian_anims,id)
		_:
			pass
	
func load_animations(data,id):
	for key in data[id].keys():
		get_node(key).set_sprite_frames(load(data[id][key]))
		get_node(key).play()
	




