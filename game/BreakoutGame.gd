extends Node2D

const FlashPointsScn = preload("res://gui/ScoredPoints.tscn")


signal game_over(total_score)


onready var bricks = $BricksMap
onready var ball = $Paddle/Ball
onready var paddle = $Paddle
onready var ballSmokes = $ParticlesBattery
onready var cameraShake = $Camera2D/ScreenShake

onready var scoreCounter = $GUI/GameHUD/ScoresHUD/AccumCounter
onready var livesCounter = $GUI/GameHUD/LivesHUD/LivesCounter
onready var ballLossArea = $BallLossArea

var currentScore := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	scoreCounter.value = currentScore
	ball.connect("ball_collided", self, "_on_ball_collided")
	bricks.connect("brickDestroyed", self, "_on_brick_destroyed")
	bricks.connect("map_cleared", self, "_on_bricksmap_cleared")
	ballLossArea.connect("ball_fell", self, "_on_ball_fallen")


func _on_ball_collided(collision: KinematicCollision2D, _ball):
	
	if (collision.collider.is_in_group("bricks")):
		cameraShake.beginShake()
		var particlesPos = collision.position - (collision.normal * 10)
		var particlesRotation = collision.normal.angle()
		ballSmokes.fireNextParticleSystem(particlesPos, particlesRotation)


func _on_brick_destroyed(type: int, tileIdx: Vector2):

	var brickPoints = _get_points_for_brick_type(type)

	var flashPoints = FlashPointsScn.instance()
	# world position of tile idx is relative to tilemap origin (0;0)
	flashPoints.global_position = (bricks.map_to_world(tileIdx) + bricks.position) - Vector2(-5, 15)
	flashPoints.text = "+%s" % brickPoints
	add_child(flashPoints)

	scoreCounter.value += brickPoints


func _get_points_for_brick_type(_type: int) -> int:
	return int(rand_range(500, 1000))


func _on_bricksmap_cleared(cleared_bricks: int):
	print("cleared brickmap with %s bricks" % cleared_bricks)


func _on_ball_fallen(ball):
	livesCounter.numExtraBalls -= 1
	if (livesCounter.numExtraBalls <= 0):
		emit_signal("game_over", scoreCounter.value)
		print("!!!GAME OVER!!!\nTOTAL SCORE:%s" % scoreCounter.value)
		ball.queue_free()
	else:
		remove_child(ball)
		paddle.attach_ball(ball)
