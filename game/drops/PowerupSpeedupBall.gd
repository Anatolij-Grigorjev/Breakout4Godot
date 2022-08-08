extends PowerupBase


signal speedup_ball_collected(speedup_coef)

export(float) var speedup_coef := 1.2


func start_in_stage(game_stage):
	.start_in_stage(game_stage)
	connect("speedup_ball_collected", game_stage, "_on_paddle_collected_ball_speedup")


func _paddle_collected_powerup():
	emit_signal("speedup_ball_collected", speedup_coef)
