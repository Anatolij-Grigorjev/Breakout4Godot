extends "PowerupBase.gd"


signal points_collected(amount)

export(float) var points_amount = 5000 setget _set_bonus_points


func start_in_stage(game_stage):
	.start_in_stage(game_stage)
	connect("points_collected", game_stage, "_on_paddle_collected_points")


func _paddle_collected_powerup():
	emit_signal("points_collected", points_amount)


func _set_bonus_points(new_amount: float):
	points_amount = new_amount
	if $Sprite/AmountLbl:
		$Sprite/AmountLbl.text = "+%d" % points_amount