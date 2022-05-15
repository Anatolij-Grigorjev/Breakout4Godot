extends Node2D


onready var mult_Lbl: Label = $HBoxContainer/MultiplierLbl


func _ready():
	var ballsInTree = get_tree().get_nodes_in_group("ball")
	if not ballsInTree.empty():
		var ball = Utils.getFirst(ballsInTree)
		ball.connect("ball_collided", self, "_on_ball_collided")
	

func _on_ball_collided(_collision: KinematicCollision2D, ball: Ball):
	_refresh_speed_multiplier(ball)


func _refresh_speed_multiplier(ball: Ball):
	mult_Lbl.text = "%s" % (ball.currentSpeed / ball.baseSpeed)