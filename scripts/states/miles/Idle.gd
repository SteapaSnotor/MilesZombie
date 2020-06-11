extends Node

"""
	Miles Idle state.
"""

signal entered
signal exited

var actor = null
var next_state = null
var transitions = []
var click_input = false
var special_input = false
var controller = null

#initialize
func init(actor,transitions):
	self.actor = actor
	self.controller = actor.controller
	self.next_state = null
	self.transitions = transitions
	self.click_input = false
	self.special_input = false
	
	#signals
	self.actor.controller.connect('clicked',self,'set_click_input')
	self.actor.controller.connect('pressed_special',self,
	'set_special_input')
	
	emit_signal("entered")

func update(delta):
	if actor == null: return
	
	check_transitions()

func check_transitions():
	#transition 0 = Walking
	#transition 1 = Attacking
	#transition 2 = Dead
	
	if actor.get_health() <= 0:
		next_state = transitions[2]
		exited()
	elif controller.is_action_pressed('go') and not actor.is_close_to_selected_enemy():
		if actor.can_walk(controller.get_last_click()):
			next_state = transitions[0]
			exited()
	elif controller.is_action_pressed('go') and actor.is_close_to_selected_enemy():
		next_state = transitions[1]
		exited()
	elif controller.is_action_pressed('special'):
		next_state = transitions[0]
		exited()
	else: return
	
func set_click_input(at):
	click_input = true

func set_special_input(at):
	special_input = true

func exited():
	#disconnect signals
	actor.controller.disconnect('pressed_special',self,'set_special_input')
	self.actor.controller.disconnect('clicked',self,'set_click_input')
	
	self.actor = null
	
	emit_signal("exited",next_state)
