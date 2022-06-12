extends Node2D

const FlashPointsScn = preload("res://gui/ScoredPoints.tscn")
const BallTrailScn = preload("res://ball/BallTrail.tscn")


signal game_over(total_score)


onready var bg = $BG/Background
onready var bricks = $BricksMap
onready var ball = $Paddle/Ball
onready var paddle = $Paddle
onready var ballSmokes = $ParticlesBattery
onready var cameraShake = $Camera2D/ScreenShake

onready var scoreCounter = $GUI/GameHUD/ScoresHUD/AccumCounter
onready var livesCounter = $GUI/GameHUD/LowerHUD/LivesHUD/MarginContainer/LivesCounter
onready var ballLossArea = $BallLossArea
onready var ballTrailTimer = $BallTrailTimer

var currentScore := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	ballTrailTimer.stop()
	scoreCounter.value = currentScore
	ballTrailTimer.connect("timeout", self, "_on_ball_trail_timeout")
	ball.connect("ball_collided", self, "_on_ball_collided")
	ball.connect("ball_speed_changed", self, "_on_ball_speed_changed")
	bricks.connect("brickDestroyed", self, "_on_brick_destroyed")
	bricks.connect("brick_damaged", self, "_on_brick_damaged")
	bricks.connect("map_cleared", self, "_on_bricksmap_cleared")
	ballLossArea.connect("ball_fell", self, "_on_ball_fallen")



func _on_ball_collided(collision: KinematicCollision2D):
	
	if (collision.collider.is_in_group("bricks")):
		cameraShake.beginShake()
		_fire_collision_particles(collision)
		bg.do_pulse(ball.currentSpeedupCoef())


func _on_ball_trail_timeout():

	var ball_trail = BallTrailScn.instance()
	ball_trail.global_position = ball.global_position
	add_child_below_node(bricks, ball_trail)



func _on_ball_speed_changed(ball: Ball):

	var speed_coef = ball.currentSpeedupCoef()
	if speed_coef > 1.5 and ballTrailTimer.is_stopped():
		ballTrailTimer.start()
	if speed_coef < 1.5 and not ballTrailTimer.is_stopped():
		ballTrailTimer.stop()


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
	ballTrailTimer.stop()
	if (livesCounter.numExtraBalls <= 0):
		emit_signal("game_over", scoreCounter.value)
		print("!!!GAME OVER!!!\nTOTAL SCORE:%s" % scoreCounter.value)
		ball.queue_free()
	else:
		remove_child(ball)
		paddle.attach_ball(ball)


func _on_bricksmap_cleared(cleared_bricks: int):
	print("cleared brickmap with %s bricks" % cleared_bricks)



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