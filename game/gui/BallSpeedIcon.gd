extends Control


onready var mult_Lbl: Label = $HBoxContainer/MultiplierLbl


func _ready():
	var ballsInTree = get_tree().get_nodes_in_group("ball")
	if not ballsInTree.empty():
		var ball = Utils.getFirst(ballsInTree)
		ball.connect("ball_speed_changed", self, "_on_ball_speed_changed")
	

func _on_ball_speed_changed(ball: Ball):
	_refresh_speed_multiplier(ball)


func _refresh_speed_multiplier(ball: Ball):
	mult_Lbl.text = "%.1f" % ball.currentSpeedupCoef()