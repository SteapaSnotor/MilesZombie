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
var attacking_tile = Vector2.ZERO

const min_attack_dis = 64

func init(actor,transitions):
	yield(actor,'new_animation')
	
	self.actor = actor
	self.transitions = transitions
	self.attacking_frame = 15 #TODO: this must come from the actor
	self.anim_node = actor.get_current_animation_node()
	
	#signals
	self.anim_node.connect('frame_changed',self,'attack')
	
	#attacking_tile = actor.get_last_path().back()
	attacking_tile = pathfinding.get_closest_tile(actor.global_position)
	attacking_tile = pathfinding.set_path_centered([attacking_tile])[0]
	attacking_tile.y += 64
	actor.set_occupied_place(attacking_tile)
	
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
	#transition 2 = Dead
	if actor.health <= 0:
		next_state = transitions[2]
		exit()
	elif not actor.is_seeing_player():
		next_state = transitions[0]
		exit()
	elif not actor.is_player_on_melee_range():
		next_state = transitions[1]
		exit()
	else: return
	

func exit():
	#disconnect signals
	anim_node.disconnect('frame_changed',self,'attack')
	actor.set_occupied_place_free(attacking_tile)
	
	actor = null
	anim_node = null
	attacking_tile = Vector2.ZERO
	emit_signal("exited",next_state)
