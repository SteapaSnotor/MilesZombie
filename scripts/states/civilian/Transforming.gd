extends Node

"""
	Civilian Transforming state.
"""

signal exited

var actor = null
var transitions = []

var next_state = null

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions
	
	actor.update_facing2(actor.get_player().get_facing_dir() * -1)
	
	actor.disable_areas()

func update(delta):
	if actor == null: return
	
	check_transitions()

func check_transitions():
	#transition 0 = ??
	#TODO
	pass
	
func exit():
	actor = null
	emit_signal("exited",next_state)
