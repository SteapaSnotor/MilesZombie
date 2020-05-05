extends Node

"""
	Civilian Idle state.
"""

signal exited

var actor = null
var transitions = []

var next_state = null

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions

func update(delta):
	if actor == null: return
	
	check_transitions()

func check_transitions():
	#transition 0 = Running
	#transition 1 = Attacking
	#transition 2 = Dead
	if actor.health <= 0:
		next_state = transitions[2]
		exit()
	elif actor.is_seeing_player():
		next_state = transitions[0]
		exit()
	
func exit():
	actor = null
	emit_signal("exited",next_state)
