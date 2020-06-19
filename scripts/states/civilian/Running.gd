extends Node

"""
	Civilian Running state.
"""

signal exited

var actor = null
var target = null
var next_state = null
var was_attacked = false
var arrived = false
var transitions = []

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions
	
	set_target()
	
	#signals
	actor.connect('attacked',self,'set_attacked')
	
func update(delta):
	if actor == null: return
	
	set_target()
	
	if actor.check_overlapping_state(['Running','Moving']):
		actor.halt_movement()
	
	#WARNING: SPAGHETTI CODE AHEAD
	if not arrived: 
		actor.is_moving = actor.run(actor.global_position,target,delta)
		if not actor.is_moving: arrived = true
	
	if arrived:
		if pathfinding.find_path(actor.global_position,target).size() > 2:
			arrived = false
		else:
			actor.move(actor.global_position,target,delta)
	
	check_transitions()
	
func check_transitions():
	#transition 0 = idle
	#transition 1 = attacking
	#transition 2 = scared
	#transition 3 = dead
	if actor.get_health() <= 0:
		next_state = transitions[3]
		exit()
	elif not actor.is_moving and actor.is_aggressive() and actor.is_player_on_melee_range():
		next_state = transitions[1]
		exit()
	elif actor.is_moving and actor.is_aggressive() and was_attacked:
		next_state = transitions[1]
		exit()
	elif not actor.is_moving and not actor.is_aggressive():
		next_state = transitions[2]
		exit()
	else: return
	
func set_target():
	if actor.is_aggressive():
		#TODO: to avoid overlapping between civilians, the AI needs
		#to go the neighbour tiles around the player. 
		target = actor.get_player().get_global_position()
		
		
	elif not actor.is_aggressive() and target == null:
		var reflected = actor.get_global_position() - actor.get_player().get_global_position()
		reflected = reflected.normalized() * 5
		var pos_reflected = actor.get_global_position() * reflected
		
		target = pathfinding.get_closest_tile(pos_reflected)
	else: return

func set_attacked():
	was_attacked = true

func exit():
	#disconnect signals
	actor.disconnect('attacked',self,'set_attacked')
	
	self.actor = null
	self.target = null
	self.was_attacked = false
	self.arrived = false
	emit_signal("exited",next_state)
