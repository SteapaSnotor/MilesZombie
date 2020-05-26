extends Node2D

"""
	Manages the level and the actors on it.
"""

signal initialized

var controller = null
var camera = null
var player = null

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

func get_path_map():
	return $GroundTiles/Pathfinding.get_child(0)
