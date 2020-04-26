extends Node2D

"""
	Handle inputs from the player.
"""

signal clicked

var _initialized = false
var _last_click = Vector2.ZERO

#initialize controller
func init():
	_initialized = true
	set_process_input(true)
	set_physics_process(true)
	
func _input(event):
	if not _initialized: set_process_input(false)
	
func _physics_process(delta):
	if not _initialized: set_physics_process(false)
	
	#detects clicks
	if Input.is_action_pressed("go"):
		var pos = get_global_mouse_position()
		if pos != _last_click: 
			_last_click = pos
			emit_signal("clicked",_last_click)
		 
	
func exit():
	_initialized = false
	set_process_input(false)
	set_physics_process(false)
