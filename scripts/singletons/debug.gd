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
var line_from = null
var line_to = null

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
		
func do_line(from,to):
	line_from = from
	line_to = to
	update()
	
	
func _draw():
	#draw any lines
	if line_from is Vector2:
		draw_line(line_from,line_to,Color.red,4.0)
	








