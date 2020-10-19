extends Node

"""
	Main game node.
	Initializes the game main elements: world and ui. 
	Also receive and update data from level, world and ui.
"""

signal new_cursor_state

var world = null
var gui = null
var level = null

var version = '0.0.1'

#intialize game
func _ready():
	#TODO: initialize main menu first
	init_world()
	init_gui()
	
func init_world():
	world = get_child(0)
	world.init()
	
	#connect stage signals
	var current_level = world.get_current_level()
	current_level.connect('enemy_selected',self,'_on_new_cursor_state',['Biting'])
	current_level.connect('enemy_unselected',self,'_on_new_cursor_state',['Default'])
	
func init_gui():
	gui = get_child(2)
	gui.init()
	
func _on_new_cursor_state(state):
	gui.update_mouse_cursor(state)
