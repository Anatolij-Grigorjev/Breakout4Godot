extends KinematicBody2D


const AfterImageScn = preload("res://paddle/AfterImage.tscn")


signal request_launch_ball
signal ball_speedup_requested
signal ball_speedup_started
signal ball_speedup_ended

export(float) var base_speed: float = 150.0
export(float) var shift_distance: float = 75.0

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
onready var leftBumperEndPos: Position2D = $LeftBumperEnd
onready var rightBumperStartPos: Position2D = $RightBumperStart


var ballRef: Node2D
var ball_attached = false
var sprite_material

var prev_direction: Vector2 = Vector2.ZERO
var this_direction_time: float = 0.0
var ball_drop_margin = 2.0

var velocity: Vector2 = Vector2.ZERO
var input_enabled = true


func _ready():
	
	sprite_material = $Sprite.material
	tween.connect("tween_all_completed", self, "_ball_bounce_done")



func disable_control():
	input_enabled = false


func enable_control():
	input_enabled = true


func _process(delta: float):

	var direction = Vector2(0, 0)
	
	if input_enabled and Input.is_action_pressed("paddle_left"):
		direction.x = -1
	if input_enabled and Input.is_action_pressed("paddle_right"):
		direction.x = 1

	if input_enabled and Input.is_action_just_released("paddle_launch_ball"):
		if ball_attached:
			_launch_ball()
		else:
			emit_signal("request_launch_ball")

	if input_enabled and Input.is_action_just_pressed("paddle_shift"):
		_shift_paddle_in_direction(direction)
	
	
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

	return (
		global_hit_pos.x < leftBumperEndPos.global_position.x 
		or global_hit_pos.x > rightBumperStartPos.global_position.x
	)



func attach_ball(ball: Ball):
	ballRef = ball
	add_child(ballRef)
	ballRef.disable_paddle_collisions()
	ball.sprite.visible = false
	ball.anim.play("appear")
	ball_attached = true
	_clamp_ball_on_paddle()



func _shift_paddle_in_direction(direction: Vector2):
	if direction.x == 0:
		return
	_spawn_after_image()
	move_and_collide(direction * shift_distance)



func _spawn_after_image():
	var instance = AfterImageScn.instance()
	get_parent().add_child(instance)
	instance.global_position = global_position


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
		get_parent().add_child(ballRef)
		ballRef.reset_speed()
		ballRef.global_position = Vector2(global_position.x, global_position.y - ballRef.colliderSize.y - ball_drop_margin)
		ballRef.enable_paddle_collisions()
		ballRef = null


func _ball_bounce_done():
	#reset sprite position fully after all bouncing done
	$Sprite.position = Vector2.ZERO



func _prepare_and_run_bounce_reaction_tweens(ball_speed_coef: float):
	tween.stop_all()
	tween.remove_all()
	var bounce_travel = base_ball_recoil * ball_speed_coef
	var future_position = $Sprite.position + Vector2(0, bounce_travel)
	var bounce_down_travel_time = 0.4
	tween.interpolate_property(
		$Sprite, 'position', 
		null, future_position, 
		bounce_down_travel_time, 
		Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	tween.interpolate_property(
		$Sprite, 'position', 
		future_position, Vector2.ZERO, 
		0.3, 
		Tween.TRANS_QUAD, Tween.EASE_IN, 
		bounce_down_travel_time
	)
	tween.start()
