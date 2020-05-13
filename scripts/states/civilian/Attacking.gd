extends Node

"""
	Civilian Attacking state.
"""

signal exited

var actor = null
var next_state = null
var anim_node = null
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
	
	actor.update_facing((actor.get_player().global_position - actor.global_position).normalized())
	
	check_transitions()

func attack():
	if anim_node.get_frame() == attacking_frame:
		actor.attack(actor.get_player())

func check_transitions():
	#transition 0 = Idle
	#transition 1 = Running
	if not actor.is_seeing_player():
		next_state = transitions[0]
		exit()
	elif not actor.is_player_on_melee_range():
		next_state = transitions[1]
		exit()
	else: return
	

func exit():
	#disconnect signals
	anim_node.disconnect('frame_changed',self,'attack')
	
	actor = null
	anim_node = null
	emit_signal("exited",next_state)
