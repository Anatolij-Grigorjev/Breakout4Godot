extends Node2D

export(Vector2) var initialBallPos = Vector2(190, 200)

onready var bricks = $BricksMap
onready var ball = $Ball
onready var ballSmokes = $ParticlesBattery
onready var cameraShake = $Camera2D/ScreenShake
onready var scoreCounter = $HitCounter

var currentScore := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	scoreCounter.score = currentScore
	ball.position = initialBallPos
	ball.connect("ball_collided", self, "_on_ball_collided")
	bricks.connect("brickDestroyed", self, "_on_brick_destroyed")


func _on_ball_collided(collision: KinematicCollision2D):
	
	cameraShake.beginShake()
	var particlesPos = collision.position - (collision.normal * 10)
	var particlesRotation = collision.normal.angle()
	ballSmokes.fireNextParticleSystem(particlesPos, particlesRotation)


func _on_brick_destroyed(type: int, pos: Vector2):
	scoreCounter.score += 1000
