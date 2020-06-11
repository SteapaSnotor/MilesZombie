extends Node

"""
	Miles Moving state.
"""

signal entered
signal exited

var actor = null
var next_state = null
var controller = null
var transitions = []
var pressed_special = false

#initialize
func init(actor,transitions):
	self.actor = actor
	self.controller = actor.controller
	self.next_state = null
	self.transitions = transitions
	
	#signals
	self.controller.connect('pressed_special',self,'set_pressed_special')
	
	emit_signal("entered")

func update(delta):
	if actor == null: return
	
	actor.is_moving = actor.move(actor.global_position,
	get_last_click(),delta)
	
	check_transitions()

func check_transitions():
	#transition 0 = Idle
	#transition 1 = Attacking
	#transition 2 = Biting
	#transition 3 = Dead
	
	if actor.get_health() <= 0:
		next_state = transitions[3]
		exited()
	elif not actor.is_moving:
		next_state = transitions[0]
		exited()
	elif actor.is_close_to_selected_enemy() and controller.is_action_pressed('go'):
		next_state = transitions[1]
		exited()
	elif actor.is_close_to_selected_enemy() and controller.is_action_pressed('special') and actor.is_selected_enemy_vulnerable():
		next_state = transitions[2]
		exited()
	else: return
	

func set_pressed_special(at):
	pressed_special = true

func get_last_click():
	if controller.is_action_pressed('go'):
		return controller.get_last_click()
	elif controller.is_action_pressed('special'):
		return controller.get_last_click_special()
	else: return controller.get_last_mouse_action_pos()
	

func exited():
	actor.is_moving = false
	
	#disconnect signals
	controller.disconnect('pressed_special',self,'set_pressed_special')
	
	pressed_special = false
	controller = null
	actor = null
	emit_signal("exited",next_state)
