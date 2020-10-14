extends Control

"""
	Manages everything about the custom graphical cursor.
"""

signal default
signal biting
signal grabbing

var current_cursor = null

#initialize mouse cursor
func init():
	update_cursor('Default')
	set_process(true)
	
	connect("default",self,'update_cursor',['Default'])
	connect("biting",self,'update_cursor',['Biting'])
	connect("grabbing",self,'update_cursor',['Grabbing'])
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

#update cursor position
func _process(delta):
	if current_cursor == null: return set_process(false)
	
	current_cursor.set_global_position(get_global_mouse_position())
	
	
func update_cursor(cname):
	if current_cursor != null: current_cursor.hide()
	
	current_cursor = get_node(cname)
	current_cursor.show()
