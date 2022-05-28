extends KinematicBody2D


export(float) var base_speed: float = 150.0

# acceleration added over seconds of consistent movement in same direction
export(float) var acceleration: float = 150.0

# base amount of travel paddle does recoiling from ball
export(float) var base_ball_recoil = 7

onready var ballSparks1x = $Sprite/ParticlesBattery
onready var ballSparks2x = $Sprite/ParticlesBattery2x
onready var ballSparks3x = $Sprite/ParticlesBattery3x
onready var tween: Tween = $Tween
onready var ballPosition: Position2D = $BallPosition


var ballRef: Node2D
var ball_attached = false
var sprite_material

var prev_direction: Vector2 = Vector2.ZERO
var this_direction_time: float = 0.0

var velocity: Vector2 = Vector2.ZERO


func _ready():
	ballRef = Utils.getFirstTreeNodeInGroup(get_tree(), "ball")
	ball_attached = _check_has_attached_ball()
	if (ball_attached):
		attach_ball(ballRef)
	sprite_material = $Sprite.material


func _process(delta: float):
	var direction = Vector2(0, 0)
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_just_released("ui_accept") and ball_attached:
		_launch_ball()
	
	if direction == prev_direction:
		this_direction_time += delta
	else:
		this_direction_time = 0
	
	var moment_speed = abs(direction.x) * (base_speed + this_direction_time * acceleration)
	sprite_material.set_shader_param("radius", _calc_speed_blur(moment_speed))
	velocity = direction * moment_speed
	move_and_collide(velocity * delta)

	prev_direction = direction



func ball_hit_at(global_hit_pos: Vector2, ball_speed_coef: float):
	_prepare_and_run_bounce_reaction_tweens(ball_speed_coef)
	var ballSparks = _pick_sparks_for_ball_hit(ball_speed_coef)
	ballSparks.fireNextParticleSystem(global_hit_pos)


func attach_ball(ball: Ball):
	ballRef = ball
	add_child(ballRef)
	ball_attached = true
	ballRef.stop()
	ballRef.position = ballPosition.position


func _check_has_attached_ball() -> bool:
	for child in get_children():
		if child.is_in_group("ball"):
			return true 
	return false


func _calc_speed_blur(current_speed: float) -> float:
	if current_speed < base_speed * 1.5:
		return 0.0
	return current_speed / (base_speed * 1.5)



func _pick_sparks_for_ball_hit(ball_speed_coef: float) -> CPUParticles2D:
	if ball_speed_coef < ballRef.maxSpeedCoef / 2:
		return ballSparks1x
	elif ball_speed_coef < ballRef.maxSpeedCoef:
		return ballSparks2x
	else:
		return ballSparks3x


func _launch_ball():
	ball_attached = false
	if ballRef:
		remove_child(ballRef)
		ballRef.reset_speed()
		get_parent().add_child(ballRef)
		ballRef.global_position = Vector2(global_position.x, global_position.y - 10)


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