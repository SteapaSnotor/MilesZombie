extends "res://scripts/char_actor.gd"

"""
	Civilian character/actor main node.
	Store data and deals with tons of AI systems e.g: FSM.
"""

signal selected
signal unselected
signal new_animation
signal infected
signal overlapping
signal overlapping_stopped

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
onready var halt_timer = $HaltTimer

var player = null setget , get_player
var enemies_on_melee_range = []
var enemies_on_sight = []
export var _is_aggressive = true setget , is_aggressive#TODO: set this on init
export var id = 0
var _player_on_sight = false setget , is_seeing_player
var _player_on_melee_range = false setget , is_player_on_melee_range
var _previous_animation_node = null
var _infected = false setget , is_infected
var _halt_time = 0.5

const default_speed = 155

func init(player):
	self.player = player
	self.speed = default_speed
	#init systems
	fsm.init(self,state_transitions)
	animation_node.init('civilian',id)
	
	#TODO: animations according to ID

func _process(delta):
	if player == null: return
	
	update_animations()
	update_grid_position()
	#print(health)
	#debug only
	$State.text = fsm.get_current_state().name
	$Info/HealthBar.value = health

func is_seeing_player():
	return _player_on_sight

func is_seeing_enemies():
	return enemies_on_sight.size() != 0

func is_aggressive():
	return _is_aggressive

func is_player_on_melee_range():
	return _player_on_melee_range

func is_enemies_on_melee_range():
	return enemies_on_melee_range.size() != 0

func is_enemy_on_melee_range(enemy):
	return enemies_on_melee_range.find(enemy) != -1

func is_infected():
	return _infected

func get_player():
	return player

func get_current_animation_node():
	return current_animation_node

func get_closest_on_sight():
	var enemies = enemies_on_sight.duplicate()
	enemies.sort_custom(self,'distance_body_sorter')
	
	return enemies.front()

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
	update_facing2((pos - get_grid_position()).normalized())

func disable_areas():
	$AIDetection.get_child(0).set_disabled(true)
	$SightDetection.get_child(0).set_disabled(true)
	$MeleeRange.get_child(0).set_disabled(true)
	$OverlapDetection.get_child(0).set_disabled(true)

func do_infection():
	emit_signal("infected",global_position,id,self)
	_infected = true

#temporary halt the civilian movement by decreasing speed
#generally used to avoid collisions between civilians.
func halt_movement(timer = false):
	if timer == true:
		speed = default_speed
		halt_timer.stop()
		halt_timer.disconnect('timeout',self,'halt_movement')
	elif halt_timer.is_stopped() and not timer:
		speed = 0
		halt_timer.connect('timeout',self,'halt_movement',[true])
		halt_timer.set_wait_time(_halt_time)
		halt_timer.start()
	else: return
	
func _on_mouse_entered():
	emit_signal("selected",self)

func _on_mouse_exited():
	emit_signal("unselected",self)

func on_sight_detection_entered(body):
	if body == player: _player_on_sight = true
		
func on_sight_detection_exited(body):
	if body == player: _player_on_sight = false

func on_enemy_detection_entered(area):
	if area.get_parent().is_in_group('PlayerAlly') and enemies_on_sight.find(area.get_parent()) == -1:
		enemies_on_sight.append(area.get_parent())
		
		if not area.get_parent().is_connected('died',self,'on_enemy_died'):
			area.get_parent().connect('died',self,'on_enemy_died')

func on_enemy_detection_exited(area):
	if enemies_on_sight.find(area.get_parent()) != -1:
		enemies_on_sight.remove(enemies_on_sight.find(area.get_parent()))

func on_entered_melee_range(body):
	if body == player: _player_on_melee_range = true

func on_exited_melee_range(body):
	if body == player: _player_on_melee_range = false

func on_enemies_entered_melee_range(area):
	if area.get_parent().is_in_group('PlayerAlly') and area.name == 'MeleeRange':
		if enemies_on_melee_range.find(area.get_parent()) == -1:
			enemies_on_melee_range.append(area.get_parent())
			
			if not area.get_parent().is_connected('died',self,'on_enemy_died'):
				area.get_parent().connect('died',self,'on_enemy_died')

func on_enemies_exited_melee_range(area):
	if area.get_parent().is_in_group('PlayerAlly'):
		if enemies_on_melee_range.find(area.get_parent()) != -1:
			enemies_on_melee_range.remove(enemies_on_melee_range.find(area.get_parent()))

func on_overlap_detection_entered(area):
	if area.name == 'OverlapDetection' and area.get_parent() != self:
		if _overlapping_bodies.find(area.get_parent()) == -1 and area.get_parent().is_in_group('Civilian'):
			_overlapping_bodies.append(area.get_parent()) 
			emit_signal('overlapping')
	
func on_overlap_detection_exited(area):
	if area.name == 'OverlapDetection' and area.get_parent() != self:
		if _overlapping_bodies.find(area.get_parent()) != -1:
			_overlapping_bodies.erase(area.get_parent())
			emit_signal('overlapping_stopped')

#when an enemy this player intereacted it dies. Remove arrays containing
#it.
func on_enemy_died(enemy):
	if enemies_on_melee_range.find(enemy) != -1:
		enemies_on_melee_range.remove(enemies_on_melee_range.find(enemy))
	
	if enemies_on_sight.find(enemy) != -1:
		enemies_on_sight.remove(enemies_on_sight.find(enemy))









