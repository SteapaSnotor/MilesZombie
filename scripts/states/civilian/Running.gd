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
	if not actor.is_moving and actor.is_aggressive():
		next_state = transitions[1]
		exit()
	

func set_target():
	if actor.is_aggressive():
		target = actor.get_player().get_global_position()
	else: pass #TODO

func exit():
	
	self.actor = null
	self.target = null
	emit_signal("exited",next_state)
