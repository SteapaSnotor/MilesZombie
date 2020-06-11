extends "res://scripts/char_actor.gd"

"""
	Manages the zombie actor. Zombies are created by the player.
	This node will handle some part of the AI, including the initialization
	of the FSM.
"""

signal new_animation

onready var states_transitions = {
	$FSM/Idle:[$FSM/Attacking,$FSM/Walking,$FSM/Dead],
	$FSM/Attacking:[$FSM/Idle,$FSM/Walking,$FSM/Dead],
	$FSM/Walking:[$FSM/Idle,$FSM/Attacking,$FSM/Dead],
	$FSM/Dead:[]
}

onready var animation_node = $Animations
onready var fsm = $FSM

var id = 0
var player = null
var current_animation_node = null

var _previous_animation_node = null

#initialize
func init(id,player):
	self.id = id
	self.player = player
	
	animation_node.init('zombie',id)
	fsm.init(self,states_transitions)

func _process(delta):
	#debug only
	$State.text = fsm.get_current_state().name
	
	update_animations()

func look_at(pos):
	update_facing((pos - global_position).normalized())

func get_player():
	return player

func get_current_animation_node():
	return current_animation_node

func update_animations():
	var anim_name = '0'
	var state = fsm.get_current_state().name
	
	anim_name = str(facing_dir.x) + '_' + str(facing_dir.y)
	current_animation_node = animation_node.get_node(state)
	
	if current_animation_node.get_animation() != anim_name or current_animation_node != _previous_animation_node:
		#play it only once
		current_animation_node.play(anim_name)
		current_animation_node.show()
	
	if current_animation_node != _previous_animation_node:
		_previous_animation_node = current_animation_node
		emit_signal("new_animation")
	
	for anim in animation_node.get_children():
		if anim.name != state: 
			anim.hide()
			anim.stop()
			anim.set_frame(0)






