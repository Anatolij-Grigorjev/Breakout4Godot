extends Node2D

onready var ball = $Ball
onready var ballSmoke = $CollideSmoke


# Called when the node enters the scene tree for the first time.
func _ready():
	ball.connect("ball_collided", self, "_on_ball_collided")


func _on_ball_collided(collision: KinematicCollision2D):
	ballSmoke.global_position = collision.position - (collision.normal * 10)
	ballSmoke.rotation = collision.normal.angle()
	ballSmoke.emitting = true
