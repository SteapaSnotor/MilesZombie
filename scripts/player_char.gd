extends "res://scripts/char_actor.gd"

"""
	Player character/actor main node.
	Store data and deals with tons of player's systems e.g: FSM.
"""

#the states that each state can transition to
onready var states_transitions= {
	$FSM/Idle:[$FSM/Moving,$FSM/Attacking],
	$FSM/Moving:[$FSM/Idle,$FSM/Attacking],
	$FSM/Attacking:[$FSM/Idle,$FSM/Moving]
}

var controller = null
var selected_enemy = null setget , get_current_enemy

onready var animation_node = $Animations
onready var fsm = $FSM

const min_attack_range = 50
const min_walking_distance = 20

#initialiazes player here
func init(controller):
	self.controller = controller
	
	#init fsm
	self.fsm.init(self,states_transitions)
	
	#signals
	self.controller.connect('clicked',self,'player_clicked')
	
#player's animations
func _process(delta):
	update_animations()
	
	#debug only: show the current state
	$State.text = fsm.get_current_state().name
	
#when player uses the go action
func player_clicked(at):
	pass
	#moved this to the fsm moving state
	#_is_moving = true
	#_moving_target = at

#updates the current animation according to its state and direction
#the player is facing.
func update_animations():
	var anim_name = '0'
	var state = fsm.get_current_state().name
	
	anim_name = str(facing_dir.x) + '_' + str(facing_dir.y)
	animation_node.get_node(state).play(anim_name)
	animation_node.get_node(state).show()
	
	for anim in animation_node.get_children():
		if anim.name != state: anim.hide()
	
#the current animation being show
func get_current_animation_node():
	return animation_node.get_node(fsm.get_current_state().name)

func get_current_enemy():
	return selected_enemy

#check if Miles is in melee range of a selected enemy
func is_close_to_selected_enemy():
	if selected_enemy == null: return false
	
	var ref = weakref(selected_enemy)
	if ref.get_ref() == null: return false
	
	if global_position.distance_to(selected_enemy.global_position) >min_attack_range:
		return false
	
	#this may be too perfomance heavy
	#var path = pathfinding.find_path(global_position,selected_enemy.global_position)
	#if path.size() > 1: return false
	
	return true
	
#TODO: test other stuff here e.g collisions
func can_walk(to):
	if to.distance_to(global_position) <= min_walking_distance:
		return false
	else: return true

func on_enemy_selected(body):
	selected_enemy = body

func on_enemy_unselected(body):
	if selected_enemy == body: selected_enemy = null
