extends KinematicBody2D
class_name Ball

signal ball_collided(collision)
signal ball_speed_changed(ball)

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite

export(float) var bounceSpeedupCoef: float = 1.15
export(float) var maxSpeedCoef: float = 2.5

export(float) var baseSpeed: float = 120
export(float) var baseSpinDegrees: float = 360.0
export(Vector2) var direction := Vector2.LEFT

var baseSpinRadians = deg2rad(baseSpinDegrees)
var speedAdditive = baseSpeed * bounceSpeedupCoef - baseSpeed
var spinAdditive = baseSpinRadians * bounceSpeedupCoef - baseSpinRadians

var currentSpeed
var currentSpinRadians


func _ready():
	reset_speed()


func reset_speed():
	_set_current_speed_and_broadcast(baseSpeed)
	currentSpinRadians = baseSpinRadians


func stop():
	_set_current_speed_and_broadcast(0)
	currentSpinRadians = 0


func currentSpeedupCoef() -> float:
	return currentSpeed / max(baseSpeed, 1.0)


func _process(delta: float):
	var collision: KinematicCollision2D = move_and_collide(direction * currentSpeed * delta)
	sprite.rotate(currentSpinRadians * delta)
	_handle_potential_collision(collision)
		


func _set_current_speed_and_broadcast(new_speed_val: float):
	currentSpeed = new_speed_val
	sprite.material.set_shader_param("radius", max(0.0, currentSpeedupCoef() - 1.5))
	emit_signal("ball_speed_changed", self)


func _handle_potential_collision(collision: KinematicCollision2D):
	if (not collision):
		return
	
	var next_direction = direction.bounce(collision.normal)


	if not collision.collider.is_in_group("barrier"):
		sprite.rotation = collision.normal.angle()
	
	if collision.collider.is_in_group("bricks"):
		_speedup_ball()
		anim.play("hit-squish")
		var tilemap: BricksMap = collision.collider as BricksMap
		tilemap.bricks_hit_at(collision.position, collision.normal)
	
	if collision.collider.is_in_group("paddle"):
		var paddle = collision.collider
		paddle.ball_hit_at(collision.position, currentSpeedupCoef())
		next_direction = (next_direction + paddle.velocity.normalized()).normalized()
	
	direction = _adjust_horizontal_bounce_direction(next_direction, collision.collider)
		
	emit_signal("ball_collided", collision)


func _speedup_ball():
	_set_current_speed_and_broadcast(clamp(currentSpeed + speedAdditive, baseSpeed, baseSpeed * maxSpeedCoef))
	currentSpinRadians = clamp(currentSpinRadians + spinAdditive, baseSpinRadians, baseSpinRadians * maxSpeedCoef)


func _adjust_horizontal_bounce_direction(original_direction: Vector2, collider: Node2D) -> Vector2:
	var current_angle = original_direction.angle()
	var allowed_adjustmenet = rand_range(PI / 12, PI / 6)
	var new_direction = original_direction
	if abs(current_angle) < PI / 6:
		new_direction = new_direction.rotated(sign(current_angle) * allowed_adjustmenet)
		print("(on %s): land angle: %s (%s rad) not exciting, adjusted for %s (%s rad) to %s" % [collider, rad2deg(current_angle), current_angle, rad2deg(allowed_adjustmenet), allowed_adjustmenet, rad2deg(new_direction.angle())])
	elif abs(current_angle) > PI * 5 / 6:
		new_direction = new_direction.rotated(-sign(current_angle) * allowed_adjustmenet)
		print("(on %s): land angle: %s (%s rad) not exciting, adjusted for %s (%s rad) to %s" % [collider, rad2deg(current_angle), current_angle, rad2deg(allowed_adjustmenet), allowed_adjustmenet, rad2deg(new_direction.angle())])
	return new_direction
