extends "res://scripts/char_actor.gd"

"""
	Civilian character/actor main node.
	Store data and deals with tons of AI systems e.g: FSM.
"""

signal selected
signal unselected

onready var state_transitions = {
	$FSM/Idle:[$FSM/Running,$FSM/Attacking,$FSM/Dead],
	$FSM/Running:[$FSM/Idle],
	$FSM/Dead:[]
}

onready var fsm = $FSM

var player = null

func init(player):
	self.player = player
	
	#init systems
	fsm.init(self,state_transitions)

func _process(delta):
	if player == null: return
	#print(health)
	#debug only
	$State.text = fsm.get_current_state().name
	$Info/HealthBar.value = health

func _on_mouse_entered():
	emit_signal("selected",self)

func _on_mouse_exited():
	emit_signal("unselected",self)
