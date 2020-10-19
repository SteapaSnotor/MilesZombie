extends Node

"""
	Manages everything about the graphical user interface
	in the game.
"""

onready var cursor = $MouseLayer/MouseCursor

#initialize the gui
func init():
	init_mouse()

func init_mouse():
	cursor.init()

func get_layers():
	pass
	
func get_layer(lname):
	return

func update_mouse_cursor(cname):
	cursor.update_cursor(cname)
