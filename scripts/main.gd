extends Node

"""
	Main game node.
	Initializes the game main elements: world and ui. 
	Also receive and update data from level, world and ui.
"""

var world = null
var gui = null
var level = null

var version = '0.0.1'

#intialize game
func _ready():
	#TODO: initialize main menu first
	init_world()
	pass
	
func init_world():
	world = get_child(0)
	world.init()
	
	#TODO: connect signals

func init_gui():
	pass
	

