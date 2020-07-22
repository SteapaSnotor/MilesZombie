extends "res://scripts/char_actor.gd"

"""
	Manages the zombie actor. Zombies are created by the player.
	This node will handle some part of the AI, including the initialization
	of the FSM.
"""

signal new_animation
signal overlapping
signal overlapping_stopped

onready var states_transitions = {
	$FSM/Idle:[$FSM/Attacking,$FSM/Walking,$FSM/Dead],
	$FSM/Attacking:[$FSM/Idle,$FSM/Walking,$FSM/Dead],
	$FSM/Walking:[$FSM/Idle,$FSM/Attacking,$FSM/Dead],
	$FSM/Dead:[]
}

onready var animation_node = $Animations
onready var fsm = $FSM
onready var halt_timer = $HaltTimer

var id = 0
var player = null
var current_animation_node = null

var _previous_animation_node = null
var _enemies_on_sight = []
var _enemies_on_melee_range = []
var _halt_time = 0.5
var _seeing_player = false

const default_speed = 150
const player_max_distance = 200

#initialize
func init(id,player):
	self.id = id
	self.player = player
	self.speed = default_speed
	
	animation_node.init('zombie',id)
	fsm.init(self,states_transitions)

func _process(delta):
	#debug only
	$State.text = fsm.get_current_state().name
	
	update_animations()
	update_grid_position()

func look_at(pos):
	update_facing((pos - global_position).normalized())

func get_player():
	return player

func get_current_animation_node():
	return current_animation_node

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

func is_seeing_enemies():
	return _enemies_on_sight.size() != 0

func is_seeing_player():
	return _seeing_player

func is_enemy_on_melee_range(enemy):
	return _enemies_on_melee_range.find(enemy) != -1

#returns the closest enemy that this zombie is seeing
func get_closest_on_sight():
	var enemies = _enemies_on_sight.duplicate()
	enemies.sort_custom(self,'distance_body_sorter')
	
	return enemies.front()

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

func disable_areas():
	$MeleeRange.get_child(0).set_disabled(true)
	$SightDetection.get_child(0).set_disabled(true)
	$OverlapDetection.get_child(0).set_disabled(true)

func _on_enemy_sight_entered(area):
	if area.name == 'AIDetection' and _enemies_on_sight.find(area.get_parent()) == -1:
		if area.get_parent().get_groups().find('Enemy')  != -1:
			var body = area.get_parent()
			if not body.is_connected('died',self,'_on_enemy_died'): body.connect('died',self,'_on_enemy_died')
			_enemies_on_sight.append(area.get_parent())

func _on_enemy_sight_exited(area):
	if _enemies_on_sight.find(area.get_parent()) != -1:
		_enemies_on_sight.remove(_enemies_on_sight.find(area.get_parent()))

func _on_player_sight_entered(body):
	if body == get_player(): _seeing_player = true

func _on_player_sight_exited(body):
	if body == get_player(): _seeing_player = false

func _on_melee_range_entered(area):
	if area.name == 'MeleeRange':
		var body = area.get_parent()
		if _enemies_on_melee_range.find(body) == -1:
			if not body.is_connected('died',self,'_on_enemy_died'): body.connect('died',self,'_on_enemy_died')
			_enemies_on_melee_range.append(body)
	
func _on_melee_range_exited(area):
	if area.name == 'MeleeRange':
		var body = area.get_parent()
		if _enemies_on_melee_range.find(body) != -1:
			_enemies_on_melee_range.remove(_enemies_on_melee_range.find(body))

func on_overlap_detection_entered(area):
	if area.name == 'OverlapDetection' and area.get_parent() != self:
		if _overlapping_bodies.find(area.get_parent()) == -1:
			if area.get_parent().is_in_group('Zombie'):
				_overlapping_bodies.append(area.get_parent()) 
				emit_signal('overlapping')
	
func on_overlap_detection_exited(area):
	if area.name == 'OverlapDetection' and area.get_parent() != self:
		if _overlapping_bodies.find(area.get_parent()) != -1:
			_overlapping_bodies.erase(area.get_parent())
			emit_signal('overlapping_stopped')

#when a enemy that this zombie saw/see or is fighting/fought, dies.
#remove it from arrays.
func _on_enemy_died(enemy):
	if _enemies_on_melee_range.find(enemy) != -1:
		_enemies_on_melee_range.remove(_enemies_on_melee_range.find(enemy))
	
	if _enemies_on_sight.find(enemy) != -1:
		_enemies_on_sight.remove(_enemies_on_sight.find(enemy))
	

