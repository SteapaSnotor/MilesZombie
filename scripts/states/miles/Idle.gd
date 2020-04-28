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

#initialize
func init(actor,transitions):
	self.actor = actor
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
	
	if click_input == true:
		#TODO: check if he's not hovering the UI
		#TODO: check if he's not attacking
		click_input = false
		next_state = transitions[0]
		exited()
	elif special_input:
		#TODO: different state
		#TODO: check if he has specials? mana?
		next_state = transitions[1]
		exited()
	
	
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
