extends Node2D

"""
	Manages the level and the actors on it.
"""

signal initialized
signal enemy_selected
signal enemy_unselected
signal box_selected
signal box_unselected

var controller = null
var camera = null
var player = null

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
			object.connect('selected',self,'_on_enemy_selected')
			object.connect('unselected',self,'_on_enemy_unselected')
			object.connect('infected',self,'add_zombie')
			
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

func get_path_map():
	return $GroundTiles/Pathfinding.get_child(0)

func get_z_tree():
	return $ActorsAndTiles

func _on_enemy_selected(enemy):
	emit_signal("enemy_selected")

func _on_enemy_unselected(enemy):
	emit_signal("enemy_unselected")
