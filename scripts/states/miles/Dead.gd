extends Node

"""
	Miles Dead state
"""

signal entered
signal exited

var actor = null
var transitions = []

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions
	
	emit_signal("entered")

func update(delta):
	if actor == null: return
	
	

func exit():
	
	emit_signal("exited")
