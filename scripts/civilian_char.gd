extends "res://scripts/char_actor.gd"

"""
	Civilian character/actor main node.
	Store data and deals with tons of AI systems e.g: FSM.
"""

onready var state_transitions = {
	$FSM/Idle:[$FSM/Running],
	$FSM/Running:[$FSM/Idle]
}

onready var fsm = $FSM

var player = null

func init(player):
	self.player = player
	
	#init systems
	fsm.init(self,state_transitions)

func _process(delta):
	if player == null: return
	
	#debug only
	$State.text = fsm.get_current_state().name
