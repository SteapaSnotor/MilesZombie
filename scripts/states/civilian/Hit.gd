extends Node

"""
	Civilian Hit state.
"""

signal exited

var actor = null
var anim_node = null
var transitions = []
var hit_frame = 0
var animation_ended = false
var next_state = null

func init(actor,transitions):
	yield(actor,'new_animation')
	
	self.actor = actor
	self.transitions = transitions
	self.hit_frame = 8 #TODO: this must come from the actor
	self.anim_node = actor.get_current_animation_node()
	
	#signals
	actor.connect('attacked',self,'set_new_hit')
	anim_node.connect('animation_finished',self,'set_animation_end')
	
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
	elif animation_ended:
		next_state = transitions[1]
		exit()
	
func set_new_hit():
	anim_node.set_frame(hit_frame)

func set_animation_end():
	animation_ended = true

func exit():
	#disconnect signals
	actor.disconnect('attacked',self,'set_new_hit')
	anim_node.disconnect('animation_finished',self,'set_animation_end')
	
	actor = null
	anim_node = null
	animation_ended = false
	emit_signal("exited",next_state)
