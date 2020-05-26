extends Node

"""
	Civilian Hit state.
"""

signal exited

var actor = null
var anim_node = null
var transitions = []
var hit_frame = 0

var next_state = null

func init(actor,transitions):
	yield(actor,'new_animation')
	
	self.actor = actor
	self.transitions = transitions
	self.hit_frame = 8 #TODO: this must come from the actor
	self.anim_node = actor.get_current_animation_node()
	
	#signals
	actor.connect('attacked',self,'set_new_hit')
	
func update(delta):
	if actor == null: return
	
	check_transitions()

func check_transitions():
	#transition 0 = Scared
	#transition 1 = Running
	#transition 2 = Dead
	if actor.health <= 0:
		next_state = transitions[2]
		exit()
	
func set_new_hit():
	anim_node.set_frame(hit_frame)
	print(anim_node.name)

func exit():
	#disconnect signals
	actor.disconnect('attacked',self,'set_new_hit')
	
	actor = null
	anim_node = null
	emit_signal("exited",next_state)
