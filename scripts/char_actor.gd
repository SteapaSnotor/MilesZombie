extends Node2D

"""
	Base class for character actors in the game.
	This includes enemies.
"""

var speed = 150
var facing_dir = Vector2.DOWN

#run from a place to another. Returns false if is already in place
func run(from,to,delta,min_distance = 5):
	#TODO: reuse paths
	var path = pathfinding.find_path(from,to)
	var dir = Vector2.ZERO
	
	if path.size() > 1:
		dir = (path[1] - from).normalized()
		
	else: return false
	
	global_position += dir * speed * delta 
	update_facing(dir)
	
	return true

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
	
