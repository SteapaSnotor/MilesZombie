extends Node

"""
	Zombie Idle state.
"""

signal exited

var actor = null
var transitions = []

var next_state = null
var is_overlapping = false

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions
	
func update(delta):
	if actor == null: return
	
	if actor.check_overlapping_state(['Idle']):
		is_overlapping = true
	
	actor.look_at(actor.get_player().get_global_position())
	
	check_transitions()

func check_transitions():
	#transition 0 = Attacking
	#transition 1 = Walking
	#transition 2 = Dead
	if actor.get_health() <= 0:
		next_state = transitions[2]
		exit()
	elif actor.is_seeing_enemies():
		var closest = actor.get_closest_on_sight()
		if actor.is_enemy_on_melee_range(closest):
			next_state = transitions[0]
			exit()
		else:
			next_state = transitions[1]
			exit()
	elif is_overlapping:
		next_state = transitions[1]
		exit()
	elif actor.is_seeing_player():
		var p_player = actor.get_player().get_grid_position()
		
		if actor.get_grid_position().distance_to(p_player) > (actor.player_max_distance+50):
			next_state = transitions[1]
			exit()
	else: return
	
	
func exit():
	self.actor = null
	self.is_overlapping = false
	
	emit_signal("exited",next_state)
