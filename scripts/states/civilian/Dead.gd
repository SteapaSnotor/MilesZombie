extends Node

"""
	Civilian Dead state.
"""

signal exited

var actor = null

func init(actor,transitions):
	#TODO: wait for the dying animation
	#actor.call_deferred('free')
	pass

func update(delta):
	pass

func check_transitions():
	pass

func exit():
	
	emit_signal("exited")
