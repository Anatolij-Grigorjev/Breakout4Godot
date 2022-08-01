extends PowerupBase


signal slowdown_ball_collected(slowdown_coef)

export(float) var slowdown_coef := 1.5


func _paddle_collected_powerup():
	emit_signal("slowdown_ball_collected", slowdown_coef)
