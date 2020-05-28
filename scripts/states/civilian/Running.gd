extends Node

"""
	Civilian Running state.
"""

signal exited

var actor = null
var target = null
var next_state = null
var transitions = []

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions
	
	set_target()

func update(delta):
	if actor == null: return
	
	set_target()
	
	actor.is_moving = actor.run(actor.global_position,target,delta)
	
	check_transitions()
	
func check_transitions():
	#transition 0 = idle
	#transition 1 = attacking
	#transition 2 = scared
	if not actor.is_moving and actor.is_aggressive():
		next_state = transitions[1]
		exit()
	elif not actor.is_moving and not actor.is_aggressive():
		next_state = transitions[2]
		exit()
	else: return
	

func set_target():
	if actor.is_aggressive():
		target = actor.get_player().get_global_position()
	elif not actor.is_aggressive() and target == null:
		pass #TODO
		var reflected = actor.get_global_position() - actor.get_player().get_global_position()
		reflected = reflected.normalized() * 5
		var pos_reflected = actor.get_global_position() * reflected
		
		target = pathfinding.get_closest_tile(pos_reflected)
		print(target)
	else: return

func exit():
	
	self.actor = null
	self.target = null
	emit_signal("exited",next_state)
