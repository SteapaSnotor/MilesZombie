extends "res://scripts/char_actor.gd"

"""
	Player character/actor main node.
	Store data and deals with tons of player's systems e.g: FSM.
"""

#the states that each state can transition to
onready var states_transitions= {
	$FSM/Idle:[$FSM/Moving,$FSM/Attacking],
	$FSM/Moving:[$FSM/Idle,$FSM/Attacking],
	$FSM/Attacking:[$FSM/Idle,$FSM/Moving]
}

var controller = null

onready var animation_node = $Animations
onready var fsm = $FSM

#initialiazes player here
func init(controller):
	self.controller = controller
	
	#init fsm
	self.fsm.init(self,states_transitions)
	
	#signals
	self.controller.connect('clicked',self,'player_clicked')
	
#player's animations
func _process(delta):
	update_animations()
	
	#debug only: show the current state
	$State.text = fsm.get_current_state().name
	
#when player uses the go action
func player_clicked(at):
	pass
	#moved this to the fsm moving state
	#_is_moving = true
	#_moving_target = at

#updates the current animation according to its state and direction
#the player is facing.
func update_animations():
	var anim_name = '0'
	var state = fsm.get_current_state().name
	
	anim_name = str(facing_dir.x) + '_' + str(facing_dir.y)
	animation_node.get_node(state).play(anim_name)
	animation_node.get_node(state).show()
	
	for anim in animation_node.get_children():
		if anim.name != state: anim.hide()
	
	



