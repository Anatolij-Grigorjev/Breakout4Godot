extends KinematicBody2D


export(float) var speed: float = 150.0

onready var ballSparks = $Sprite/ParticlesBattery
onready var anim: AnimationPlayer = $AnimationPlayer
onready var ballPosition: Position2D = $BallPosition


var attachedBall: Node2D


func _ready():
	if ($Ball):
		attachedBall = $Ball
		attachedBall.stop()


func _process(delta: float):
	var direction = Vector2(0, 0)
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_just_released("ui_accept") and attachedBall:
		_detach_ball()
	
	move_and_collide(direction * speed * delta)


func ball_hit_at(global_hit_pos: Vector2, hit_normal: Vector2):
	anim.play("bounce_ball")
	ballSparks.fireNextParticleSystem(global_hit_pos)


func attach_ball(ball: Ball):
	attachedBall = ball
	add_child(attachedBall)
	attachedBall.stop()
	attachedBall.position = ballPosition.position


func _detach_ball():
	remove_child(attachedBall)
	attachedBall.reset()
	get_parent().add_child(attachedBall)
	attachedBall.global_position = Vector2(global_position.x, global_position.y - 10)
	attachedBall = null