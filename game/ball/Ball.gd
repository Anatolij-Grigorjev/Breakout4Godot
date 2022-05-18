extends KinematicBody2D
class_name Ball

signal ball_collided(collision, ball)

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite

export(float) var bounceSpeedupCoef: float = 1.1
export(float) var maxSpeedCoef: float = 3.0

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
	currentSpeed = baseSpeed
	currentSpinRadians = baseSpinRadians

func stop():
	currentSpeed = 0
	currentSpinRadians = 0


func _process(delta: float):
	var collision: KinematicCollision2D = move_and_collide(direction * currentSpeed * delta)
	sprite.rotate(currentSpinRadians * delta)
	_handle_potential_collision(collision)



func _handle_potential_collision(collision: KinematicCollision2D):
	if (not collision):
		return

	var new_direction = direction.bounce(collision.normal)

	if not collision.collider.is_in_group("barrier"):
		sprite.rotation = collision.normal.angle()
	
	if collision.collider.is_in_group("bricks"):
		_speedup_ball()
		anim.play("hit-squish")
		var tilemap: BricksMap = collision.collider as BricksMap
		tilemap.bricks_hit_at(collision.position, collision.normal)
	
	if collision.collider.is_in_group("paddle"):
		var paddle = collision.collider
		paddle.ball_hit_at(collision.position, collision.normal)
		#adjust new direction to be more exiciting (central in release)
		var current_angle = new_direction.angle()
		var allowed_adjustmenet = rand_range(PI / 12, PI / 6)
		print("land angle: %s" % rad2deg(current_angle))
		if abs(current_angle) < PI / 6:
			new_direction = new_direction.rotated(sign(current_angle) * allowed_adjustmenet)
			print("not exciting, adjusted for %s to %s" % [rad2deg(allowed_adjustmenet), rad2deg(new_direction.angle())])
		elif abs(current_angle) > PI * 5 / 6:
			new_direction = new_direction.rotated(-sign(current_angle) * allowed_adjustmenet)
			print("not exciting, adjusted for %s to %s" % [rad2deg(allowed_adjustmenet), rad2deg(new_direction.angle())])
		
			
	emit_signal("ball_collided", collision, self)
	direction = new_direction


func _speedup_ball():
	currentSpeed = clamp(currentSpeed + speedAdditive, baseSpeed, baseSpeed * maxSpeedCoef)
	currentSpinRadians = clamp(currentSpinRadians + spinAdditive, baseSpinRadians, baseSpinRadians * maxSpeedCoef)