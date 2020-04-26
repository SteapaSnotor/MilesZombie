extends Node2D

"""
	Load and unload level and store player's data.
	Also receives information from the level to be used in the main node.
"""

signal level_loaded
signal loading_level

var levels = {
	0:preload('res://scenes/levels/Level0.tscn').instance()
}

var current_level = levels[0]

#initialize world
func init():
	load_current_level()

func load_current_level():
	emit_signal("loading_level")
	
	add_child(current_level)
	#TODO: init level
	emit_signal("level_loaded")
	
func unload_level():
	pass
