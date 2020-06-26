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
var console = null
var console_open = false

func _input(event):
	if event.is_action_pressed("console"):
		set_console_open(!console_open)

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
	
#open and closes the console
func set_console_open(open):
	console_open = open
	
	if console_open:
		#add and init the console here
		console = load('res://scenes/Console.tscn').instance()
		self.add_child(console)
		console.init(tree.root.get_node('Main').version)
		
		#connect signals here
		console.connect('fill_grid',self,'fill_grid')
		
	else:
		console.queue_free()

func fill_grid(centered):
	var main = get_parent().get_node('Main')
	var level = main.world.current_level
	var grid_map = level.get_path_map()
	var grid_real = []
	
	for tile in grid_map.get_used_cells():
		grid_real.append(grid_map.map_to_world(tile))
	
	if centered == 'true':
		grid_real = pathfinding.set_path_centered(grid_real)
	
	highlight_path(grid_real,level)


