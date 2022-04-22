extends Node2D

export(Vector2) var initialBallPos = Vector2(190, 200)

onready var ball = $Ball
onready var ballSmokes = $ParticlesBattery


# Called when the node enters the scene tree for the first time.
func _ready():
	ball.position = initialBallPos
	ball.connect("ball_collided", self, "_on_ball_collided")


func _on_ball_collided(collision: KinematicCollision2D):
	
	var particlesPos = collision.position - (collision.normal * 10)
	var particlesRotation = collision.normal.angle()
	ballSmokes.fireNextParticleSystem(particlesPos, particlesRotation)
