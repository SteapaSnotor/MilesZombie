extends "res://scripts/char_actor.gd"

"""
	Player character/actor main node.
	Reacts mainly to events.
"""

var controller = null
var _is_moving = false
var _moving_target = Vector2.ZERO

onready var animation_node = $Animations

#initialiazes player here
func init(controller):
	self.controller = controller
	
	#signals
	self.controller.connect('clicked',self,'move')

#player's movement
func _physics_process(delta):
	if _is_moving:
		_is_moving = run(global_position,_moving_target,delta)
	

#player's animations
func _process(delta):
	update_animations()
	
	
func move(to):
	_is_moving = true
	_moving_target = to
	

func update_animations():
	#TODO: update it according to its states
	var anim_name = '0'
	anim_name = str(facing_dir.x) + '_' + str(facing_dir.y)
	animation_node.get_child(0).play(anim_name)
	





