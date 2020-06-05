extends Node

"""
	Miles Biting state
"""

signal entered
signal exited

var actor = null
var transitions = []

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions
	
	actor.get_current_enemy().do_infection()
	
	emit_signal("entered")

func update(delta):
	if actor == null: return
	
	

func exit():
	
	emit_signal("exited")
