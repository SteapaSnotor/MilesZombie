extends Node

"""
	Miles Attacking state.
"""

signal entered
signal exited

var actor = null
var next_state = null
var controller = null
var attack_anim = null
var attack_frame = 0
var transitions = []
var has_attacked = false

#initialize
func init(actor,transitions):
	self.actor = actor
	self.next_state = null
	self.controller = actor.controller
	self.transitions = transitions
	self.attack_anim = actor.get_current_animation_node()
	self.attack_frame = 6 #TODO: this must come from the actor
	
	#connect signals
	attack_anim.set_frame(0)
	attack_anim.connect('frame_changed',self,'attack')
	
	emit_signal("entered")

func update(delta):
	if actor == null: return
	
	if actor.get_current_enemy() != null:
		
		#update the player's facing according to the current enemy
		actor.update_facing2(actor.get_global_position().direction_to(actor.get_current_enemy().get_global_position()))

	else:
		#update the player's facing acording to the mouse
		actor.update_facing((controller.get_last_click() - actor.global_position).normalized())
	
	check_transitions()

#check if the animation is in the right frame, then call attack.
func attack():
	if attack_anim.get_frame() == attack_frame:
		has_attacked = true
		
		#check if actor is close enough distance
		#TODO:that will be unecessary later on when  being close will be
		#one of the requirements to change to this sate
		if actor.selected_enemy == null: return
		#if actor.selected_enemy.global_position.distance_to(actor.global_position)< 70:
		actor.attack(actor.selected_enemy)

func check_transitions():
	#$FSM/Idle,$FSM/Moving,$FSM/Biting,$FSM/Dead
	#transition 0 = Idle
	#transition 1 = Moving
	#transition 2 = Biting
	#transition 3 = Dead
	
	if actor.get_health() <= 0:
		next_state = transitions[3]
		exited()
	elif not controller.is_action_pressed('go') and not controller.is_action_pressed('special'):
		if has_attacked == true:
			next_state = transitions[0]
			exited()
	elif not actor.is_close_to_selected_enemy() and controller.is_action_pressed('go'):
		if has_attacked == true:
			next_state = transitions[1]
			exited()
	elif actor.is_close_to_selected_enemy() and controller.is_action_pressed('special'):
		if actor.is_selected_enemy_vulnerable():
			next_state = transitions[2]
			exited()
	else: return
	
	
func exited():
	#disconnect signals
	attack_anim.disconnect('frame_changed',self,'attack')
	
	self.actor = null
	self.attack_anim = null
	self.has_attacked = false
	
	emit_signal("exited",next_state)
