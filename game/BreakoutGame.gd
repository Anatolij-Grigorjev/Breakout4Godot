extends Node2D

const FlashPointsScn = preload("res://gui/ScoredPoints.tscn")
const BallTrailScn = preload("res://ball/BallTrail.tscn")
const BallScn = preload("res://ball/Ball.tscn")


signal game_over(total_score)


onready var bg = $BG/Background
onready var bricks = $BricksMap
onready var paddle = $Paddle
onready var ballSmokes = $ParticlesBattery
onready var camera = $Camera2D
onready var cameraShake = $Camera2D/ScreenShake

onready var scoreCounter = $GUI/GameHUD/ScoresHUD/AccumCounter
onready var livesCounter = $GUI/GameHUD/LowerHUD/LivesHUD/MarginContainer/LivesCounter
onready var gameEndMessage = $GUI/GameEndMessage
onready var ballLossArea = $BallLossArea

var currentScore := 0

var stageFinished = false


# Called when the node enters the scene tree for the first time.
func _ready():
	scoreCounter.value = currentScore
	#hook first ball up
	$Paddle/Ball.connect("ball_collided", self, "_on_ball_collided")

	bricks.connect("brickDestroyed", self, "_on_brick_destroyed")
	bricks.connect("brick_damaged", self, "_on_brick_damaged")
	bricks.connect("map_cleared", self, "_on_bricksmap_cleared")
	ballLossArea.connect("ball_fell", self, "_on_ball_fallen")

	paddle.connect("ball_speedup_requested", self, "_on_paddle_ball_speedup_requested")
	paddle.connect("ball_speedup_started", self, "_on_paddle_ball_speedup_started")
	paddle.connect("ball_speedup_ended", self, "_on_paddle_ball_speedup_ended")
	paddle.connect("request_launch_ball", self, "_on_paddle_new_ball_requested")


func _process(delta):
	if stageFinished and Input.is_action_just_released("ui_accept"):
		_reset_stage()



func _reset_stage():
	stageFinished = false
	_hide_stage_end_message()

	for ball in _get_active_balls():
		ball.queue_free()
	
	var ball = _create_new_ball()
	paddle.attach_ball(ball)
	paddle.enable_control()

	scoreCounter.value = 0.0
	livesCounter.numExtraBalls = 3

	bricks.reset_bricks()


func _on_paddle_new_ball_requested():
	if livesCounter.numExtraBalls <= 0 or paddle.ball_attached:
		return
	
	livesCounter.numExtraBalls -= 1
	var new_ball = _create_new_ball()
	paddle.attach_ball(new_ball)



func _on_ball_collided(ball: Ball, collision: KinematicCollision2D):
	
	if (collision.collider.is_in_group("bricks")):
		cameraShake.beginShake()
		_fire_collision_particles(collision)
		bg.do_pulse(ball.currentSpeedupCoef())


func _on_paddle_ball_speedup_requested():
	#only speedup not attached ball
	if paddle.ball_attached:
		return

	for ball in _get_active_balls():
		if ball.is_at_max_speed():
			ball.stop_glowing()
			continue
		ball.speedup_ball()


func _on_paddle_ball_speedup_started():

	if paddle.ball_attached:
		return
	
	for ball in _get_active_balls():
		if ball.is_at_max_speed():
			continue
		ball.glow()


func _on_paddle_ball_speedup_ended():

	if paddle.ball_attached:
		return
	
	for ball in _get_active_balls():
		ball.stop_glowing()
	


func _on_brick_damaged(tile_idx: Vector2, old_type: int, new_type: int):
	print("brick at %s changed type: %s -> %s" % [tile_idx, old_type, new_type])


func _on_brick_destroyed(type: int, tileIdx: Vector2):

	var brickPoints = _get_points_for_brick_type(type)
	# brick position is relative to tilemap parent
	var brick_origin_pos = bricks.map_to_world(tileIdx) + bricks.position
	_add_scored_points_bubble(brick_origin_pos, brickPoints)
	scoreCounter.value += brickPoints


func _on_ball_fallen(ball):

	var num_balls_in_scene = _get_active_balls().size()
	if num_balls_in_scene > 1:
		ball.queue_free()
		return
	if (livesCounter.numExtraBalls <= 0):
		emit_signal("game_over", scoreCounter.value)
		ball.stop()
		_show_stage_end_message("GAME OVER\nSCORE: " + str(scoreCounter.value))
		paddle.disable_control()
		stageFinished = true
	else:
		livesCounter.numExtraBalls -= 1
		remove_child(ball)
		paddle.attach_ball(ball)


func _on_bricksmap_cleared(cleared_bricks: int):
	print("cleared brickmap with %s bricks" % cleared_bricks)
	stageFinished = true
	for ball in _get_active_balls():
		ball.currentSpeed = 0.0
	paddle.disable_control()
	_show_stage_end_message("SUCCESS\nSCORE: " + str(scoreCounter.value))


func _show_stage_end_message(message: String):
	gameEndMessage.visible = true
	gameEndMessage.get_node("HBoxContainer/Label").text = message
	gameEndMessage.get_node("AnimationPlayer").play("show")


func _hide_stage_end_message():
	gameEndMessage.visible = false


func _get_points_for_brick_type(type: int) -> float:
	var base_points = bricks.get_points_for_brick_type(type)
	return base_points # * ball.currentSpeedupCoef()


func _fire_collision_particles(collision: KinematicCollision2D):
	var particlesPos = collision.position - (collision.normal * 10)
	var particlesRotation = collision.normal.angle()
	ballSmokes.fireNextParticleSystem(particlesPos, particlesRotation)


func _add_scored_points_bubble(score_origin: Vector2, points: float):
	var flashPoints = FlashPointsScn.instance()
	flashPoints.global_position = score_origin - Vector2(-5, 15)
	flashPoints.text = "+%s" % int(points)
	add_child(flashPoints)


func _get_active_balls() -> Array:
	return get_tree().get_nodes_in_group("ball")

func _create_new_ball():
	var ball =  BallScn.instance()
	ball.connect("ball_collided", self, "_on_ball_collided")
	return ball
