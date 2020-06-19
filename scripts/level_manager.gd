extends Node2D

"""
	Manages the level and the actors on it.
"""

signal initialized

var controller = null
var camera = null
var player = null
var occupied_tiles = []

#time (in seconds) to an actor to become a zombie.
const infection_time = 4

#for debug only, remove this before shipping.
func _ready():
	if get_tree().get_root().get_children().find(self) != -1:
		print('Main node not found. Level initializing by itself.')
		init() #inits itself for debugging purposes only.

#initialize level
func init():
	#starts A* algorithm
	pathfinding.init(get_path_map(),Vector2(64,64),true)
	
	#initialize player controller
	controller = $PlayerController
	controller.init()
	
	#initialize player
	player = $ActorsAndTiles/Miles
	player.init(controller)
	
	#initialize the player's camera
	camera = $PlayerCamera
	camera.init(player)
	
	#initialize the enemies
	init_AI()
	
	
	emit_signal("initialized")

func init_AI():
	for object in $ActorsAndTiles.get_children():
		if object.is_in_group('Enemy'): 
			object.init(player)
			object.connect('selected',player,'on_enemy_selected')
			object.connect('unselected',player,'on_enemy_unselected')
			object.connect('infected',self,'add_zombie')
			object.connect('occupying_tile',self,'set_occupied_tile')
			object.connect('free_tile',self,'set_occupied_tile_free')
			
func add_zombie(at,id=0,actor=null,timer=null):
	if timer == null:
		var _timer = Timer.new()
		_timer.wait_time = infection_time
		_timer.one_shot = true
		_timer.connect('timeout',self,'add_zombie',[at,id,actor,_timer])
		_timer.name = 'infection_timer'
		if actor == null: add_child(_timer)
		else: actor.add_child(_timer)
		
		_timer.start()
	else:
		#spawn the zombie here
		var zombie = preload('res://scenes/Zombie.tscn').instance()
		#TODO: set zombie data 
		get_z_tree().add_child(zombie)
		zombie.global_position = at
		zombie.init(id,player)
		
		if actor != null: actor.queue_free()
		timer.queue_free()

func update_AI_tiles_info():
	for object in $ActorsAndTiles.get_children():
		if object.is_in_group('Enemy'): 
			object.occupied_tiles = get_occupied_tiles()

func get_path_map():
	return $GroundTiles/Pathfinding.get_child(0)

#returns all tiles in the level that are current being used by someone
#else.
func get_occupied_tiles():
	return occupied_tiles

func set_occupied_tile(tile):
	var final_tile = pathfinding.get_closest_tile(tile)
	final_tile.x += 32
	final_tile.y -= 32
	
	occupied_tiles.append(final_tile)
	
	debug.highlight_path(occupied_tiles,self)
	update_AI_tiles_info()

func set_occupied_tile_free(tile):
	var final_tile = pathfinding.get_closest_tile(tile)
	final_tile.x += 32
	final_tile.y -= 32
	
	occupied_tiles.remove(occupied_tiles.find(final_tile))
	
	debug.highlight_path(occupied_tiles,self)
	update_AI_tiles_info()

func get_z_tree():
	return $ActorsAndTiles
