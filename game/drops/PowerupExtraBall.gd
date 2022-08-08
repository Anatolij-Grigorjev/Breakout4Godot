extends PowerupBase


signal extra_ball_collected


func start_in_stage(game_stage):
	.start_in_stage(game_stage)
	connect("extra_ball_collected", game_stage, "_on_paddle_collected_extra_ball")


func _paddle_collected_powerup():
	emit_signal("extra_ball_collected")
