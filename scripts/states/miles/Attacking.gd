extends Node

"""
	Miles Attacking state.
"""

signal entered
signal exited

var actor = null
var next_state = null
var controller = null
var transitions = []

#initialize
func init(actor,transitions):
	self.actor = actor
	self.next_state = null
	self.controller = actor.controller
	self.transitions = transitions
	
	emit_signal("entered")

func update(delta):
	if actor == null: return
	
	actor.attack(controller.get_last_click_special())
	
	check_transitions()

func check_transitions():
	#transition 0 = Idle
	#transition 1 = Moving
	if not controller.is_action_pressed('special') and not controller.is_action_pressed('go'):
		next_state = transitions[0]
		exited()
	elif not controller.is_action_pressed('special') and controller.is_action_pressed('go'):
		next_state = transitions[1]
		exited()
		pass
	
	
func exited():
	self.actor = null
	
	emit_signal("exited",next_state)
