extends Node2D

const FlashPointsScn = preload("res://gui/ScoredPoints.tscn")
const BallTrailScn = preload("res://ball/BallTrail.tscn")


signal game_over(total_score)


onready var bg = $BG/Background
onready var bricks = $BricksMap
onready var ball = $Paddle/Ball
onready var paddle = $Paddle
onready var ballSmokes = $ParticlesBattery
onready var camera = $Camera2D
onready var cameraShake = $Camera2D/ScreenShake

onready var scoreCounter = $GUI/GameHUD/ScoresHUD/AccumCounter
onready var livesCounter = $GUI/GameHUD/LowerHUD/LivesHUD/MarginContainer/LivesCounter
onready var gameEndMessage = $GUI/GameEndMessage
onready var ballLossArea = $BallLossArea

var currentScore := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	scoreCounter.value = currentScore
	ball.connect("ball_collided", self, "_on_ball_collided")
	bricks.connect("brickDestroyed", self, "_on_brick_destroyed")
	bricks.connect("brick_damaged", self, "_on_brick_damaged")
	bricks.connect("map_cleared", self, "_on_bricksmap_cleared")
	ballLossArea.connect("ball_fell", self, "_on_ball_fallen")
	paddle.connect("ball_speedup_requested", self, "_on_paddle_ball_speedup_requested")
	paddle.connect("ball_speedup_started", self, "_on_paddle_ball_speedup_started")
	paddle.connect("ball_speedup_ended", self, "_on_paddle_ball_speedup_ended")



func _on_ball_collided(collision: KinematicCollision2D):
	
	if (collision.collider.is_in_group("bricks")):
		cameraShake.beginShake()
		_fire_collision_particles(collision)
		bg.do_pulse(ball.currentSpeedupCoef())


func _on_paddle_ball_speedup_requested():
	#only speedup not attached ball
	if paddle.ball_attached:
		return
	if ball.is_at_max_speed():
		ball.stop_glowing()
		return
	
	ball.speedup_ball()


func _on_paddle_ball_speedup_started():

	if paddle.ball_attached:
		return
	if ball.is_at_max_speed():
		return

	ball.glow()


func _on_paddle_ball_speedup_ended():

	if paddle.ball_attached:
		return
	
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
	livesCounter.numExtraBalls -= 1
	if (livesCounter.numExtraBalls <= 0):
		emit_signal("game_over", scoreCounter.value)
		ball.queue_free()
		_show_stage_end_message("GAME OVER\nSCORE: " + str(scoreCounter.value))
		paddle.disable_control()
	else:
		remove_child(ball)
		paddle.attach_ball(ball)


func _on_bricksmap_cleared(cleared_bricks: int):
	print("cleared brickmap with %s bricks" % cleared_bricks)
	ball.currentSpeed = 0.0
	paddle.disable_control()
	_show_stage_end_message("SUCCESS\nSCORE: " + str(scoreCounter.value))


func _show_stage_end_message(message: String):
	gameEndMessage.visible = true
	gameEndMessage.get_node("HBoxContainer/Label").text = message
	gameEndMessage.get_node("AnimationPlayer").play("show")


func _get_points_for_brick_type(type: int) -> float:
	var base_points = bricks.get_points_for_brick_type(type)
	return base_points * ball.currentSpeedupCoef()


func _fire_collision_particles(collision: KinematicCollision2D):
	var particlesPos = collision.position - (collision.normal * 10)
	var particlesRotation = collision.normal.angle()
	ballSmokes.fireNextParticleSystem(particlesPos, particlesRotation)


func _add_scored_points_bubble(score_origin: Vector2, points: float):
	var flashPoints = FlashPointsScn.instance()
	flashPoints.global_position = score_origin - Vector2(-5, 15)
	flashPoints.text = "+%s" % int(points)
	add_child(flashPoints)
