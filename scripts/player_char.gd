extends "res://scripts/char_actor.gd"

"""
	Player character/actor main node.
	Store data and deals with tons of player's systems e.g: FSM.
"""

signal new_animation

#the states that each state can transition to
onready var states_transitions= {
	$FSM/Idle:[$FSM/Moving,$FSM/Attacking,$FSM/Dead],
	$FSM/Moving:[$FSM/Idle,$FSM/Attacking,$FSM/Dead],
	$FSM/Attacking:[$FSM/Idle,$FSM/Moving,$FSM/Dead],
	$FSM/Dead:[]
}

var controller = null
var selected_enemy = null setget , get_current_enemy
var enemies_in_melee_range = []
var _previous_animation_node = null

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
	#debug only: update health bar
	$Info/HealthBar.value = health
	
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
	
	if animation_node.get_node(state) != _previous_animation_node:
		_previous_animation_node = animation_node.get_node(state)
		emit_signal("new_animation")
	
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
	
	if enemies_in_melee_range.find(selected_enemy) != -1: return true
	else: return false
	
	""" Old code used simple vector distance
	if global_position.distance_to(selected_enemy.global_position) >min_attack_range:
		return false
	
	#this may be too perfomance heavy
	#var path = pathfinding.find_path(global_position,selected_enemy.global_position)
	#if path.size() > 1: return false
	
	return true
	"""
	
#TODO: test other stuff here e.g collisions
func can_walk(to):
	if to.distance_to(global_position) <= min_walking_distance:
		return false
	elif test_move(get_transform(),(to - global_position).normalized()):
		return false
	else: return true

func on_enemy_selected(body):
	selected_enemy = body

func on_enemy_unselected(body):
	if selected_enemy == body: selected_enemy = null

func _on_entered_melee_range(area):
	var parent = area.get_parent()
	if area.name == 'MeleeRange' and enemies_in_melee_range.find(parent) == -1 :
		enemies_in_melee_range.append(area.get_parent())
	
func _on_exited_melee_range(area):
	var parent = area.get_parent()
	if area.name == 'MeleeRange' and enemies_in_melee_range.find(parent) != -1:
		enemies_in_melee_range.remove(enemies_in_melee_range.find(parent))
