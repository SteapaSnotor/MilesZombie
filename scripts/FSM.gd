extends Node

"""
	A simple finite state machine.
"""

var states = []
var rules = {}
var current_state = null
var actor = null

#initialize
func init(actor,transition_rules):
	self.actor = actor
	self.rules = transition_rules
	states = get_children()
	
	for state in states:
		state.connect('exited',self,'new_state')
		
	new_state(states[0])

#update the current state
func _physics_process(delta):
	if current_state != null:
		current_state.update(delta)

#a new state is set
func new_state(state):
	current_state = state
	current_state.init(actor,rules[state])
	#current_state.init(actor,rules[state])

func get_current_state():
	return current_state
