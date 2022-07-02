extends KinematicBody2D

signal ball_speedup_requested
signal ball_speedup_started
signal ball_speedup_ended

export(float) var base_speed: float = 150.0

# acceleration added over seconds of consistent movement in same direction
export(float) var acceleration: float = 150.0

# how high does speed need to be above base to start seeing speed blur
export(float) var blur_base_speed_coef: float = 1.2

# base amount of travel paddle does recoiling from ball
export(float) var base_ball_recoil = 7

#cooldown before the ball speedup gets reqeusted while holding key
export(float) var ball_speedup_cooldown = 0.25

onready var paddle_hit_sparks = $PaddleHitSparks
onready var tween: Tween = $Tween
onready var ballPosition: Position2D = $BallPosition
onready var cooldownTimer: Timer = $Timer


var ballRef: Node2D
var ball_attached = false
var sprite_material

var prev_direction: Vector2 = Vector2.ZERO
var this_direction_time: float = 0.0

var velocity: Vector2 = Vector2.ZERO
var input_enabled = true

func _ready():
	ballRef = Utils.getFirstTreeNodeInGroup(get_tree(), "ball")
	ball_attached = _check_has_attached_ball()
	if ball_attached:
		_clamp_ball_on_paddle()
	sprite_material = $Sprite.material
	cooldownTimer.wait_time = ball_speedup_cooldown
	cooldownTimer.connect("timeout", self, "_on_speedup_cooldown_done")


func disable_control():
	input_enabled = false


func _process(delta: float):

	var direction = Vector2(0, 0)
	
	if input_enabled and Input.is_action_pressed("paddle_left"):
		direction.x = -1
	if input_enabled and Input.is_action_pressed("paddle_right"):
		direction.x = 1
	if input_enabled and Input.is_action_just_released("paddle_launch_ball") and ball_attached:
		_launch_ball()
	if input_enabled and Input.is_action_pressed("paddle_ball_speedup"):
		_ensure_speedup_cooldown_active()
	else:
		_stop_speedup_cooldown()
	
	
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
	paddle_hit_sparks.fire_hit_sparks(global_hit_pos, ball_speed_coef)


func attach_ball(ball: Ball):
	ballRef = ball
	add_child(ballRef)
	ball_attached = true
	_clamp_ball_on_paddle()


func _ensure_speedup_cooldown_active():
	if cooldownTimer.is_stopped():
		cooldownTimer.start()
		$AnimationPlayer.play("glow")
		$Sprite/GlowFX.show_behind_parent = false
		emit_signal("ball_speedup_started")


func _stop_speedup_cooldown():
	if not cooldownTimer.is_stopped():
		cooldownTimer.stop()
		$AnimationPlayer.stop()
		$Sprite/GlowFX.material.set_shader_param("outline_width", 0.0)
		$Sprite/GlowFX.show_behind_parent = true
		emit_signal("ball_speedup_ended")


func _on_speedup_cooldown_done():
	emit_signal("ball_speedup_requested")


func _clamp_ball_on_paddle():
	ballRef.stop()
	ballRef.position = ballPosition.position


func _check_has_attached_ball() -> bool:
	for child in get_children():
		if child.is_in_group("ball"):
			return true 
	return false


func _calc_speed_blur(current_speed: float) -> float:
	if current_speed < base_speed * blur_base_speed_coef:
		return 0.0
	return current_speed / (base_speed * blur_base_speed_coef)


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