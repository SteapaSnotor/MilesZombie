extends Node

"""
	Zombie Dead state.
"""

signal exited

var actor = null
var transitions = []

var next_state = null

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions
	
	actor.disable_areas()

func update(delta):
	if actor == null: return
	
	check_transitions()

func check_transitions():
	pass
	
func exit():
	actor = null
	emit_signal("exited",next_state)
