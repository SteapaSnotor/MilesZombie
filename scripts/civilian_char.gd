extends "res://scripts/char_actor.gd"

"""
	Civilian character/actor main node.
	Store data and deals with tons of AI systems e.g: FSM.
"""

signal selected
signal unselected
signal new_animation
signal infected

onready var state_transitions = {
	$FSM/Idle:[$FSM/Running,$FSM/Attacking,$FSM/Dead,$FSM/Scared],
	$FSM/Running:[$FSM/Idle,$FSM/Attacking,$FSM/Scared,$FSM/Dead],
	$FSM/Attacking:[$FSM/Idle,$FSM/Running,$FSM/Dead],
	$FSM/Scared:[$FSM/Running,$FSM/Hit,$FSM/Transforming,$FSM/Dead],
	$FSM/Hit:[$FSM/Scared,$FSM/Running,$FSM/Transforming,$FSM/Dead],
	$FSM/Transforming:[$FSM/Dead],
	$FSM/Dead:[]
}

onready var fsm = $FSM
onready var animation_node = $Animations
onready var current_animation_node = $Animations/Idle setget , get_current_animation_node

var player = null setget , get_player
export var _is_aggressive = true setget , is_aggressive#TODO: set this on init
export var id = 0
var _player_on_sight = false setget , is_seeing_player
var _player_on_melee_range = false setget , is_player_on_melee_range
var _previous_animation_node = null

func init(player):
	self.player = player
	
	#init systems
	fsm.init(self,state_transitions)
	animation_node.init('civilian',id)
	
	#TODO: animations according to ID

func _process(delta):
	if player == null: return
	
	update_animations()
	
	#print(health)
	#debug only
	$State.text = fsm.get_current_state().name
	$Info/HealthBar.value = health

func is_seeing_player():
	return _player_on_sight

func is_aggressive():
	return _is_aggressive

func is_player_on_melee_range():
	return _player_on_melee_range

func get_player():
	return player

func get_current_animation_node():
	return current_animation_node

#updates the current animation according to its state and direction
#the player is facing.
func update_animations():
	var anim_name = '0'
	var state = fsm.get_current_state().name
	
	anim_name = str(facing_dir.x) + '_' + str(facing_dir.y)
	current_animation_node = animation_node.get_node(state)
	
	if current_animation_node.get_animation() != anim_name or current_animation_node != _previous_animation_node:
		#play it only once
		current_animation_node.play(anim_name)
		current_animation_node.show()
	
	if current_animation_node != _previous_animation_node:
		_previous_animation_node = current_animation_node
		emit_signal("new_animation")
	
	for anim in animation_node.get_children():
		if anim.name != state: 
			anim.hide()
			anim.stop()
			anim.set_frame(0)

func look_at(pos):
	update_facing((pos - global_position).normalized())

func do_infection():
	emit_signal("infected")

func _on_mouse_entered():
	emit_signal("selected",self)

func _on_mouse_exited():
	emit_signal("unselected",self)

func on_sight_detection_entered(body):
	if body == player: _player_on_sight = true
		
func on_sight_detection_exited(body):
	if body == player: _player_on_sight = false

func on_entered_melee_range(body):
	if body == player: _player_on_melee_range = true

func on_exited_melee_range(body):
	if body == player: _player_on_melee_range = false
