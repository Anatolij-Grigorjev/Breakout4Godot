extends KinematicBody2D
class_name Ball

signal ball_collided(collision)

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite

export(float) var bounceSpeedupCoef: float = 1.2
export(float) var maxSpeedCoef: float = 2.5

export(float) var baseSpeed: float = 99
export(float) var baseSpinDegrees: float = 360.0
export(Vector2) var direction := Vector2.LEFT

var currentSpeed
var baseSpinRadians
var currentSpinRadians
var speedAdditive
var spinAdditive


func _ready():
	currentSpeed = baseSpeed
	baseSpinRadians = deg2rad(baseSpinDegrees)
	currentSpinRadians = baseSpinRadians
	speedAdditive = baseSpeed * bounceSpeedupCoef - baseSpeed
	spinAdditive = baseSpinRadians * bounceSpeedupCoef - baseSpinRadians


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
		_speedup_ball()
	
	if collision.collider.is_in_group("bricks"):
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
		if abs(current_angle) < PI / 6 or abs(current_angle) > (5 * PI / 6):
			new_direction = new_direction.rotated(allowed_adjustmenet * sign(current_angle))
			print("not exciting, adjusted to %s" % rad2deg(new_direction.angle()))
		
			
	emit_signal("ball_collided", collision)
	direction = new_direction


func _speedup_ball():
	currentSpeed = clamp(currentSpeed + speedAdditive, baseSpeed, baseSpeed * maxSpeedCoef)
	currentSpinRadians = clamp(currentSpinRadians + spinAdditive, baseSpinRadians, baseSpinRadians * maxSpeedCoef)