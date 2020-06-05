extends Node

"""
	Civilian Scared state.
"""

signal exited

var actor = null
var transitions = []

var next_state = null
var under_attack = false setget set_attacked

func init(actor,transitions):
	self.actor = actor
	self.transitions = transitions
	
	#signals
	actor.connect('attacked',self,'set_attacked',[true])
	
func update(delta):
	if actor == null: return
	
	actor.look_at(actor.get_player().get_global_position())
	
	check_transitions()

func check_transitions():
	#transition 0 = Running
	#transition 1 = Hit
	#transition 2 = Transforming
	#transition 3 = Dead
	if actor.get_health() <= 0:
		next_state = transitions[3]
		exit()
	elif under_attack:
		next_state = transitions[1]
		exit()
	else: return
	
func set_attacked(value):
	under_attack = value

func exit():
	#disconnect signals
	actor.disconnect('attacked',self,'set_attacked')
	
	actor = null
	under_attack = false
	emit_signal("exited",next_state)











