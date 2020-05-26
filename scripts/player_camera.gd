extends Camera2D

"""
	Custom camera for the player.
"""

var player = null

var _is_following_player = false

func init(player):
	self.player = player
	
	follow_player()

#camera movement
func _process(delta):
	if _is_following_player:
		global_position = self.player.get_global_position()
		
		pass
	else: return

func move(to):
	pass
	
func jump(to):
	pass

func shake(amount):
	pass

func follow_player():
	_is_following_player = true

func stop_following_player():
	_is_following_player = false
	
func zoom_in():
	pass

func zoom_out():
	pass
