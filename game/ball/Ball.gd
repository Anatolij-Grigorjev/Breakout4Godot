extends KinematicBody2D
class_name Ball

signal ball_collided(collision)

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite

export(float) var baseSpeed: float = 99;
export(Vector2) var direction := Vector2.LEFT;

var currentSpeed

var spinRadians = deg2rad(360)

func _ready():
	currentSpeed = baseSpeed

func _process(delta: float):
	var collision: KinematicCollision2D = move_and_collide(direction * currentSpeed * delta)
	sprite.rotate(spinRadians * delta)
	_handle_potential_collision(collision)



func _handle_potential_collision(collision: KinematicCollision2D):
	if (not collision):
		return
	
	if collision.collider.is_in_group("bricks"):
		var tilemap: BricksMap = collision.collider as BricksMap
		tilemap.bricks_hit_at(collision.position, collision.normal)
		sprite.rotation = collision.normal.angle()
		anim.play("hit-squish")
		currentSpeed = clamp(currentSpeed * 1.05, baseSpeed, baseSpeed * 2)
			
	emit_signal("ball_collided", collision)
	direction = direction.bounce(collision.normal)
