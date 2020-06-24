extends KinematicBody2D

"""
	Base class for character actors in the game.
	This includes enemies.
"""

signal attacked
signal occupying_tile
signal free_tile

var speed = 150
var health = 100 setget set_health, get_health
var facing_dir = Vector2.DOWN
var current_path = []
var last_path = []
var current_target = Vector2.ZERO
var is_moving = false
var _overlapping_bodies = [] setget , get_overlapping_bodies
var occupied_tiles = []

#Run from a place to another using pathfinding. 
#Returns false if is already in place.
func run(from,to,delta,min_distance = 5):
	#TODO: reuse paths
	#TODO: maybe tha AI won't need offsets
	#small offset
	#var to_offset = Vector2(to.x-64,to.y+128) 
	var to_offset = Vector2(to.x,to.y+128) 
	var from_offset = Vector2(from.x,from.y+128)
	var dir = Vector2.ZERO
	var current_tile = Vector2.ZERO
	
	if current_path.empty() or current_target.distance_to(to) >20:
		current_path = pathfinding.find_path(from_offset,to_offset)
		last_path = current_path.duplicate()
		#debug.highlight_path(current_path,get_parent())
	
	current_target = to
	
	if current_path.size() > 1:
		dir = (current_path[1] - from).normalized()
		current_tile = current_path[1]
	else: 
		current_path =[]
		return false
		
	if current_tile.distance_to(from) <= min_distance:
		current_path.remove(current_path.find(current_tile))
		
		if current_path.size() == 0:
			return false
		
	global_position += dir * speed * delta 
	update_facing(dir)
	
	#debug.highlight_path(current_path,get_parent())
	
	return true

#moves without pathfinding.
func move(from,to,delta,min_distance = 20):
	var dir = (to - from).normalized()
	
	if from.distance_to(to) <= min_distance:
		return false
	else: 
		update_facing(dir)
		
		if dir.round() == Vector2.UP or dir.round() == Vector2.DOWN or dir.round() == Vector2.LEFT or dir.round() == Vector2.RIGHT:
			dir = dir.round()
			
		if move_and_collide(dir * speed * delta) != null: return false
		return true
	

func attack(body):
	#attacks someone
	#TODO: body should be a vector, but actor with this class as a base
	#TODO: hit calculations must be applied here
	body.health -= 10
	pass
	#var dir = (body - global_position).normalized()
	#update_facing(dir)
	

func clear_current_path():
	current_path = []

#returns true if two bodies are overlapping and have a given state(s)
func check_overlapping_state(state):
	for body in _overlapping_bodies:
		if get_index() < body.get_index():
			if state.find(body.fsm.get_current_state().name) != -1:
				return true
		
	return false

func get_health():
	return health

func get_facing_dir():
	return facing_dir

func get_overlapping_bodies():
	return _overlapping_bodies

func get_last_path():
	return last_path

func get_attacking_target(target):
	var target_offset = Vector2(target.x,target.y+64) 
	
	var attacking_points = pathfinding.get_neighbours(target_offset)
	debug.highlight_path(pathfinding.set_path_centered(attacking_points),get_parent())

func set_health(value):
	health = value
	emit_signal("attacked")

func set_occupied_place(pos):
	emit_signal("occupying_tile",pos)

func set_occupied_place_free(pos):
	emit_signal("free_tile",pos)

#update the vectors that tells where the player is moving
func update_facing(facing):
	#need to convert without normalizing since round() and floor() is
	#giving me weird results
	var real_facing = facing.round()
	
	if real_facing.x == -0: real_facing.x = 0
	if real_facing.y == -0: real_facing.y = 0

	if real_facing.x > 0: real_facing.x = 1.0
	elif real_facing.x < 0: real_facing.x = -1.0
	
	if real_facing.y > 0: real_facing.y = 1.0
	elif real_facing.y < 0: real_facing.y = -1.0
	
	facing_dir = real_facing
	
#like update_facing, but only > one-quarter cases being rounded to zero
func update_facing2(facing):
	#need to convert without normalizing since round() and floor() is
	#giving me weird results
	#var real_facing = facing.round()
	
	#manual rounding
	var real_facing = facing.round()
	if abs(facing.x) >= 0.15:
		if facing.x > 0: real_facing.x = 1
		else: real_facing.x = -1
		
	if abs(facing.y) >= 0.15:
		if facing.y > 0: real_facing.y = 1
		else: real_facing.y = -1
	
	if real_facing.x == -0: real_facing.x = 0
	if real_facing.y == -0: real_facing.y = 0

	if real_facing.x > 0: real_facing.x = 1.0
	elif real_facing.x < 0: real_facing.x = -1.0
	
	if real_facing.y > 0: real_facing.y = 1.0
	elif real_facing.y < 0: real_facing.y = -1.0
	
	facing_dir = real_facing
