extends PowerupBase


signal speedup_ball_collected(speedup_coef)

export(float) var speedup_coef := 1.2


func _paddle_collected_powerup():
	emit_signal("speedup_ball_collected", speedup_coef)
