extends Node

"""
	Zombie Walking state.
"""

signal exited

var actor = null
var target = null
var is_overlapping = false
var is_overlapping_idle = false
var is_moving_towards_player = false
var transitions = []
var next_state = null
var d_target = ''

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions

func update(delta):
	if actor == null: return
	
	if actor.check_overlapping_state(['Idle']) and not actor.is_seeing_enemies():
		is_overlapping_idle = true
	
	set_target()
	
	if actor.check_overlapping_state(['Running','Walking']):
		actor.halt_movement()
	
	if actor.check_overlapping_state(['Attacking']):
		is_overlapping = true
		
	if is_overlapping:
		is_overlapping = actor.move_away(target,delta)
	
	if is_overlapping_idle:
		is_overlapping_idle = actor.move_away(target,delta)
	
	if not is_overlapping and not is_overlapping_idle:
		actor.is_moving = actor.run(actor.get_grid_position(),target,delta)
	
	check_transitions()

func check_transitions():
	#transition 0 = Idle
	#transition 1 = Attacking
	#transition 2 = Dead
	if actor.get_health() <= 0:
		next_state = transitions[2]
		exit()
	elif actor.is_seeing_enemies():
		if actor.is_enemy_on_melee_range(actor.get_closest_on_sight()) and not is_overlapping:
			next_state = transitions[1]
			exit()
	elif is_moving_towards_player:
		var player_p = actor.get_player().get_grid_position()
		if not actor.is_seeing_player() or player_p.distance_to(actor.get_grid_position()) < actor.player_max_distance:
			next_state = transitions[0]
			exit()
	elif not is_moving_towards_player and not actor.is_seeing_enemies() and not is_overlapping_idle:
		next_state = transitions[0]
		exit()
	else: return

func set_target():
	var player_p = actor.get_player().get_grid_position()
	
	if not actor.is_seeing_enemies() and player_p.distance_to(actor.get_grid_position()) > actor.player_max_distance and not is_overlapping_idle:
		target = actor.get_player().get_grid_position()
		is_moving_towards_player = true
	elif is_overlapping_idle:
		target = actor.get_player().get_grid_position()
	elif actor.is_seeing_enemies():
		target = actor.get_closest_on_sight().get_grid_position()
		if target == actor.get_grid_position():
			pass
	else: return
	
func exit():
	actor = null
	target = null
	is_overlapping = false
	is_overlapping_idle = false
	is_moving_towards_player = false
	emit_signal("exited",next_state)
