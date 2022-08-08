extends PowerupBase


signal slowdown_ball_collected(slowdown_coef)

export(float) var slowdown_coef := 1.5


func start_in_stage(game_stage):
	.start_in_stage(game_stage)
	connect("slowdown_ball_collected", game_stage, "_on_paddle_collected_ball_slowdown")


func _paddle_collected_powerup():
	emit_signal("slowdown_ball_collected", slowdown_coef)
