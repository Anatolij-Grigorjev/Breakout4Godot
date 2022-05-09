extends Node2D


const FlashPointsScn = preload("res://gui/ScoredPoints.tscn")

onready var bricks = $BricksMap
onready var ball = $Ball
onready var ballSmokes = $ParticlesBattery
onready var cameraShake = $Camera2D/ScreenShake
onready var scoreCounter = $TotalScore
onready var livesCounter = $LivesCounter
onready var ballLossArea = $BallLossArea

var currentScore := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	scoreCounter.value = currentScore
	ball.connect("ball_collided", self, "_on_ball_collided")
	bricks.connect("brickDestroyed", self, "_on_brick_destroyed")
	ballLossArea.connect("ball_fell", self, "_on_ball_fallen")


func _on_ball_collided(collision: KinematicCollision2D):
	
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


func _get_points_for_brick_type(_type: int) -> float:
	return 1000.0


func _on_ball_fallen(_ball):
	livesCounter.numExtraBalls -= 1