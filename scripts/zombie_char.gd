extends "res://scripts/char_actor.gd"

"""
	Manages the zombie actor. Zombies are created by the player.
	This node will handle some part of the AI, including the initialization
	of the FSM.
"""

onready var states_transitions = {
	$FSM/Idle:[$FSM/Attacking,$FSM/Walking,$FSM/Dead],
	$FSM/Attacking:[$FSM/Idle,$FSM/Walking,$FSM/Dead],
	$FSM/Walking:[$FSM/Idle,$FSM/Attacking,$FSM/Dead],
	$FSM/Dead:[]
}

onready var animation_node = $Animations
onready var fsm = $FSM

var id = 0

#initialize
func init(id,player):
	self.id = id
	
	animation_node.init('zombie',id)
	fsm.init(self,states_transitions)

func _process(delta):
	#debug only
	$State.text = fsm.get_current_state().name
	












