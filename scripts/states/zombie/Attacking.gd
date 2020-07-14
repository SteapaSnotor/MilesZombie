extends Node

"""
	Zombie Attacking state.
"""

signal exited

var actor = null
var attacking_enemy = null
var next_state = null
var anim_node = null
var transitions = []
var attacking_frame = 0
var is_overlapping = false

func init(actor,transitions):
	yield(actor,'new_animation')
	
	self.actor = actor
	self.transitions = transitions
	self.attacking_enemy = actor.get_closest_on_sight()
	self.attacking_frame = 5 #TODO: this must come from somewhere else
	self.anim_node = self.actor.get_current_animation_node()
	
	#signals
	anim_node.connect('frame_changed',self,'attack')
	
func update(delta):
	if actor == null: return
	
	if actor.check_overlapping_state(['Attacking']):
		is_overlapping = true
	
	#look at the enemy the zombie is attacking
	if actor.is_enemy_on_melee_range(attacking_enemy):
		actor.look_at(attacking_enemy.get_global_position())
		
	check_transitions()

func check_transitions():
	#transition 0 = Idle
	#transition 1 = Walking
	#transition 2 = Dead
	if actor.get_health() <= 0:
		next_state = transitions[2]
		exit()
	elif actor.is_seeing_enemies() and not actor.is_enemy_on_melee_range(attacking_enemy):
		next_state = transitions[1]
		exit()
	elif actor.is_seeing_enemies() and is_overlapping:
		next_state = transitions[1]
		exit()
	elif not actor.is_seeing_enemies(): 
		next_state = transitions[0]
		exit()
	else: return

#try to attack the enemy
func attack():
	if anim_node.get_frame() == attacking_frame and attacking_enemy != null:
		actor.attack(attacking_enemy)

func exit():
	#disconnect signals
	anim_node.disconnect('frame_changed',self,'attack')
	
	actor = null
	anim_node = null
	is_overlapping = false
	emit_signal("exited",next_state)
