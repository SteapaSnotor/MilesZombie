extends Node2D

"""
	Debug singleton.
	Manages the debug console/debug functions.
"""

var debug_textures = {
	'highlight':preload('res://sprites/prototype_phase/square3.png')
}

onready var tree = get_tree()

var previous_highlight = []

func highlight_path(path,where):
	#clear previous highlight
	for point in previous_highlight:
		point.queue_free()
	previous_highlight.clear()
	
	for point in path:
		var spr = Sprite.new()
		spr.texture = debug_textures['highlight']
		where.add_child(spr)
		spr.global_position = point
		previous_highlight.append(spr)
		
