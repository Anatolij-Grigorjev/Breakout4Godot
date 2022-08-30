extends Node2D

export(PackedScene) var ball_trail_scene
export(float) var show_trail_speed_coef = 1.5

onready var trail_timer: Timer = $Timer

onready var ball = get_parent()

func _ready():
	trail_timer.stop()
	trail_timer.connect("timeout", self, "_on_trail_gen_timeout")
	ball.connect("ball_speed_changed", self, "_on_ball_speed_changed")



func _on_trail_gen_timeout():

	var ball_trail = ball_trail_scene.instance()
	#make sure trail is of same size as ball
	ball_trail.scale = ball.scale
	ball_trail.global_position = ball.global_position
	ball.get_parent().add_child(ball_trail)


func _on_ball_speed_changed(ball: Ball):

	var speed_coef = ball.currentSpeedupCoef()
	if speed_coef > show_trail_speed_coef and trail_timer.is_stopped():
		trail_timer.start()
	if speed_coef < show_trail_speed_coef and not trail_timer.is_stopped():
		trail_timer.stop()
