extends Node

"""
	Civilian Attacking state.
"""

signal exited

var actor = null

func init(actor,transitions):
	self.actor = actor

func update(delta):
	if actor == null: return
	
	check_transitions()

func check_transitions():
	
	
	pass

func exit():
	actor = null
	emit_signal("exited")
