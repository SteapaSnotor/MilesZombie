extends Node

"""
	Civilian Idle state.
"""

signal exited

func init(actor,transitions):
	pass

func update(delta):
	pass

func check_transitions():
	pass

func exit():
	
	emit_signal("exited")
