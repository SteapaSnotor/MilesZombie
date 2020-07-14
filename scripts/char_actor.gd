extends KinematicBody2D

"""
	Base class for character actors in the game.
	This includes enemies.
"""

signal attacked
signal occupying_tile
signal free_tile
signal died

var speed = 150
var health = 100 setget set_health, get_health
var facing_dir = Vector2.DOWN
var current_path = []
var last_path = []
var current_target = Vector2.ZERO
var is_moving = false
var _overlapping_bodies = [] setget , get_overlapping_bodies
var occupied_tiles = []
var grid_position = Vector2.ZERO setget , get_grid_position
var previous_neighbours = []
var current_moving_away = Vector2.ZERO
var _moving_index = 1

#Run from a place to another using pathfinding. 
#Returns false if is already in place.
func run(from,to,delta,min_distance = 5):
	#TODO: reuse paths
	#TODO: maybe tha AI won't need offsets
	#small offset
	#var to_offset = Vector2(to.x-64,to.y+128) 
	var to_offset = Vector2(to.x,to.y) 
	var from_offset = Vector2(from.x,from.y)
	var dir = Vector2.ZERO
	var current_tile = Vector2.ZERO
	
	if current_path.empty() or current_target.distance_to(to) >20:
		current_path = pathfinding.find_path(from_offset,to_offset)
		last_path = current_path.duplicate()
	#	debug.highlight_path(current_path,get_parent())
		
	current_target = to
	if current_path.size() > 1:
		dir = (current_path[1] - global_position).normalized()
		current_tile = current_path[1]
	else: 
		current_path =[]
		return false
		
	if current_tile.distance_to(global_position) <= min_distance:
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

#move away from a given position, going toward one of the 4 neighbouring
#tiles.
func move_away(from,delta):
	var offset_from = Vector2(from.x,from.y+32)
	var neighbours = [
		pathfinding.set_path_centered([pathfinding.get_closest_tile(Vector2(offset_from.x+64,offset_from.y))])[0],
		pathfinding.set_path_centered([pathfinding.get_closest_tile(Vector2(offset_from.x-64,offset_from.y))])[0],
		pathfinding.set_path_centered([pathfinding.get_closest_tile(Vector2(offset_from.x,offset_from.y+64))])[0],
		pathfinding.set_path_centered([pathfinding.get_closest_tile(Vector2(offset_from.x,offset_from.y-64))])[0]]
	
	neighbours.sort_custom(self,'distance_sorter')
	
	if previous_neighbours != neighbours:
		previous_neighbours = neighbours
		_moving_index = 1
	
	#debug.highlight_path(neighbours,get_parent())
	
	if current_moving_away == Vector2.ZERO:
		current_moving_away = neighbours[0]
		if current_moving_away == get_grid_position():
			current_moving_away = neighbours[_moving_index]
	
	if !run(global_position,current_moving_away,delta,20):
		current_moving_away = Vector2.ZERO
		_moving_index += 1
		
		if _moving_index > neighbours.size()-1:
			_moving_index = 1
		
		return false
	else: return true 
	
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

func check_any_overlapping():
	return _overlapping_bodies.size() != 0

func get_health():
	return health

func get_facing_dir():
	return facing_dir

func get_overlapping_bodies():
	return _overlapping_bodies

func get_last_path():
	return last_path

#TODO: this func may be too performance heavy, I need to find new ways
#to optimize it later.
func get_attacking_target(target):
	var target_offset = Vector2(target.x,target.y+32) 
	var attacking_points = pathfinding.set_path_centered(pathfinding.get_neighbours(target_offset))
	var body_tile = get_grid_position()
	#body_tile.y += 64
	
	#remove tiles that are occupied from the attacking tiles
	for tile in occupied_tiles:
		if attacking_points.find(tile) != -1:
			attacking_points.remove(attacking_points.find(tile))
			continue
	
	if attacking_points == []:
		#all tiles are occupied just return a random one
		attacking_points = pathfinding.set_path_centered(pathfinding.get_neighbours(target_offset))
		attacking_points.shuffle()
		return attacking_points[0]
	
	#sort by the closest tile from this body
	attacking_points.sort_custom(self,'distance_sorter')
	
	#debug.highlight_path(attacking_points,get_parent())
	
	return attacking_points[0]

func get_grid_position():
	return grid_position

#sort positions according to its distance to this actor.
#to be used with sort_custom().
func distance_sorter(a,b):
	if a.distance_to(global_position) < b.distance_to(global_position):
		return true
	return false

#like distance_sorter but it expects bodies instead of positions.
func distance_body_sorter(a,b):
	if a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position):
		return true
	return false

func set_health(value):
	health = value
	
	if health <= 0: emit_signal("died",self)
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
	
	if real_facing != Vector2.ZERO: facing_dir = real_facing
	
#like update_facing, but only > one-quarter cases being rounded to zero
func update_facing2(facing):
	#need to convert without normalizing since round() and floor() is
	#giving me weird results
	#var real_facing = facing.round()
	
	#manual rounding
	var real_facing = facing.round()
	
	if abs(facing.x) >= 0.30:
		if facing.x > 0: real_facing.x = 1
		else: real_facing.x = -1
		
	if abs(facing.y) >= 0.30:
		if facing.y > 0: real_facing.y = 1
		else: real_facing.y = -1
	
	if real_facing.x == -0: real_facing.x = 0
	if real_facing.y == -0: real_facing.y = 0

	if real_facing.x > 0: real_facing.x = 1.0
	elif real_facing.x < 0: real_facing.x = -1.0
	
	if real_facing.y > 0: real_facing.y = 1.0
	elif real_facing.y < 0: real_facing.y = -1.0
	
	if real_facing != Vector2.ZERO: facing_dir = real_facing

func update_grid_position():
	var real_pos = global_position
	#apply real offsets here
	#TODO: get this from a dictionary or property
	real_pos.y += 110
	
	var grid_pos = pathfinding.get_closest_tile(real_pos)
	#apply offsets here
	#TODO: get this from a dictionary or property
	grid_pos.x += 32 
	grid_pos.y -= 32 
	
	grid_position = grid_pos






