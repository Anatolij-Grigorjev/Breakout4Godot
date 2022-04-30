extends Node2D

onready var bricks = $BricksMap
onready var ball = $Ball
onready var ballSmokes = $ParticlesBattery
onready var cameraShake = $Camera2D/ScreenShake
onready var scoreCounter = $HitCounter

var currentScore := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	scoreCounter.score = currentScore
	ball.connect("ball_collided", self, "_on_ball_collided")
	bricks.connect("brickDestroyed", self, "_on_brick_destroyed")


func _on_ball_collided(collision: KinematicCollision2D):
	
	if (collision.collider.is_in_group("bricks")):
		cameraShake.beginShake()
		var particlesPos = collision.position - (collision.normal * 10)
		var particlesRotation = collision.normal.angle()
		ballSmokes.fireNextParticleSystem(particlesPos, particlesRotation)


func _on_brick_destroyed(type: int, pos: Vector2):
	scoreCounter.score += 1000
