extends PowerupBase


signal extra_ball_collected


func _paddle_collected_powerup():
	emit_signal("extra_ball_collected")
