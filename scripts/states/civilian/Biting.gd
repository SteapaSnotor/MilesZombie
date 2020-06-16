extends Node

"""
	Miles Biting state
"""

signal entered
signal exited

var actor = null
var next_state = null
var enemy = null
var is_enemy_on_last_frame = false
var transitions = []
var end_frame = 0

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions
	self.enemy = actor.get_current_enemy()
	self.end_frame = 19 #TODO: maybe this should come from the civ. node.
	self.next_state = null
	
	actor.update_facing2(actor.get_global_position().direction_to(enemy.get_global_position()))
	enemy.do_infection()
	yield(enemy,'new_animation')
	
	#connect signals
	enemy.get_current_animation_node().connect('frame_changed',self,'on_enemy_frame_change')
	
	
	emit_signal("entered")

func update(delta):
	if actor == null: return
	
	
	check_transitions()
	
func check_transitions():
	#transition 0 = Idle
	if is_enemy_on_last_frame:
		next_state = transitions[0]
		exit()

func on_enemy_frame_change():
	if enemy.get_current_animation_node().get_frame() == end_frame:
		is_enemy_on_last_frame = true

func exit():
	#disconnect signals
	enemy.get_current_animation_node().disconnect('frame_changed',self,'on_enemy_frame_change')
	
	is_enemy_on_last_frame = false
	enemy = null
	actor = null
	end_frame = 0 
	emit_signal("exited",next_state)


