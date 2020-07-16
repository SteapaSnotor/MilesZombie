extends Node

"""
	Civilian Attacking state.
"""

signal exited

var actor = null
var next_state = null
var anim_node = null
var target = null
var is_overlapping = false
var transitions = []
var attacking_frame = 0

const min_attack_dis = 64

func init(actor,transitions):
	yield(actor,'new_animation')
	
	self.actor = actor
	self.transitions = transitions
	self.attacking_frame = 15 #TODO: this must come from the actor
	self.anim_node = actor.get_current_animation_node()
	
	#signals
	self.anim_node.connect('frame_changed',self,'attack')
	
func update(delta):
	if actor == null: return
	
	set_target()
	
	if actor.check_overlapping_state(['Attacking']) and actor.is_aggressive():
		#two bodies attacking at the same spot
		is_overlapping = true
	
	actor.update_facing((target.global_position - actor.global_position).normalized())
	
	check_transitions()

func attack():
	if anim_node.get_frame() == attacking_frame:
		actor.attack(target)

func set_target():
	if actor.is_seeing_enemies() and actor.is_seeing_player():
		#is seeing both the player and enemies, choice the closest one.
		var c_enemy = actor.get_closest_on_sight().get_grid_position()
		var c_player = actor.get_player().get_grid_position()
			
		if actor.get_grid_position().distance_to(c_player) < actor.get_grid_position().distance_to(c_enemy):
			target = actor.get_player()
		else: target = actor.get_closest_on_sight()
			
	elif actor.is_seeing_enemies():
		#target the closest enemy
		target = actor.get_closest_on_sight()
	else:
		#target the player
		target = actor.get_player()

func check_transitions():
	#transition 0 = Idle
	#transition 1 = Running
	#transition 2 = Dead
	if actor.health <= 0:
		next_state = transitions[2]
		exit()
	elif not actor.is_seeing_player() and not actor.is_seeing_enemies():
		next_state = transitions[0]
		exit()
	elif not actor.is_player_on_melee_range() and not actor.is_enemies_on_melee_range():
		next_state = transitions[1]
		exit()
	elif is_overlapping:
		next_state = transitions[1]
		exit()
	else: return
	
func exit():
	#disconnect signals
	anim_node.disconnect('frame_changed',self,'attack')
	
	actor = null
	target = null
	anim_node = null
	is_overlapping = false
	emit_signal("exited",next_state)
