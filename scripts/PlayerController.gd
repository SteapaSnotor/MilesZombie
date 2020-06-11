extends Node2D

"""
	Handle inputs from the player.
"""

signal clicked
signal pressed_special

var _initialized = false
var _last_click = Vector2.ZERO setget , get_last_click
var _last_click_special = Vector2.ZERO setget , get_last_click_special
var _last_mouse_action = Vector2.ZERO setget , get_last_mouse_action_pos

#initialize controller
func init():
	_initialized = true
	set_process_input(true)
	set_physics_process(true)
	
func _input(event):
	if not _initialized: set_process_input(false)
	
func _physics_process(delta):
	if not _initialized: set_physics_process(false)
	
	var mouse_pos = get_global_mouse_position()
	
	#detects clicks
	if Input.is_action_pressed("go"):
		if mouse_pos != _last_click: 
			_last_click = mouse_pos
			_last_mouse_action = mouse_pos
			emit_signal("clicked",_last_click)
	elif Input.is_action_pressed("special"):
		_last_click_special = mouse_pos
		_last_mouse_action = mouse_pos
		emit_signal("pressed_special",_last_click_special)

func is_action_pressed(action):
	return Input.is_action_pressed(action)

func get_last_click():
	return _last_click

func get_last_click_special():
	return _last_click_special

func get_last_mouse_action_pos():
	return _last_mouse_action

func exit():
	_initialized = false
	set_process_input(false)
	set_physics_process(false)
