extends KinematicBody2D


export(float) var speed: float = 150.0
export(float) var base_ball_recoil = 7

onready var ballSparks1x = $Sprite/ParticlesBattery
onready var ballSparks2x = $Sprite/ParticlesBattery2x
onready var ballSparks3x = $Sprite/ParticlesBattery3x
onready var tween: Tween = $Tween
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
		_launch_ball()
	
	move_and_collide(direction * speed * delta)


func ball_hit_at(global_hit_pos: Vector2, ball_speed_coef: float):
	_prepare_and_run_bounce_reaction_tweens(ball_speed_coef)
	var ballSparks = _pick_sparks_for_ball_hit(ball_speed_coef)
	ballSparks.fireNextParticleSystem(global_hit_pos)


func attach_ball(ball: Ball):
	attachedBall = ball
	add_child(attachedBall)
	attachedBall.stop()
	attachedBall.position = ballPosition.position


func _pick_sparks_for_ball_hit(ball_speed_coef: float) -> CPUParticles2D:
	if ball_speed_coef < 1.5:
		return ballSparks1x
	elif ball_speed_coef < 2.5:
		return ballSparks2x
	else:
		return ballSparks3x


func _launch_ball():
	remove_child(attachedBall)
	attachedBall.reset_speed()
	get_parent().add_child(attachedBall)
	attachedBall.global_position = Vector2(global_position.x, global_position.y - 10)
	attachedBall = null


func _prepare_and_run_bounce_reaction_tweens(ball_speed_coef: float):
	tween.stop_all()
	tween.remove_all()
	var bounce_travel = base_ball_recoil * ball_speed_coef
	var future_position = $Sprite.position + Vector2(0, bounce_travel)
	tween.interpolate_property(
		$Sprite, 'position', 
		null, future_position, 
		0.4, 
		Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	tween.interpolate_property(
		$Sprite, 'position', 
		future_position, Vector2.ZERO, 
		0.3, 
		Tween.TRANS_QUAD, Tween.EASE_IN, 
		0.4
	)
	tween.start()