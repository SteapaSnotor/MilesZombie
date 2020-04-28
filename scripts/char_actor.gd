extends KinematicBody2D

"""
	Base class for character actors in the game.
	This includes enemies.
"""

var speed = 150
var health = 100
var facing_dir = Vector2.DOWN
var current_path = []
var is_moving = false

#Run from a place to another using pathfinding. 
#Returns false if is already in place.
func run(from,to,delta,min_distance = 5):
	#TODO: reuse paths
	#TODO: maybe tha AI won't need offsets
	#small mouse offset
	var to_offset = Vector2(to.x,to.y+64) 
	var from_offset = Vector2(from.x,from.y+128)
	var dir = Vector2.ZERO
	var current_tile = Vector2.ZERO
	
	if current_path.empty():
		current_path = pathfinding.find_path(from_offset,to_offset)
	
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
	var dir = (body - global_position).normalized()
	update_facing(dir)
	
	
func clear_current_path():
	current_path = []

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
	
