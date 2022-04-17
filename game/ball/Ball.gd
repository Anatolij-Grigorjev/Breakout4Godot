extends KinematicBody2D
class_name Ball

export(float) var speed: float = 20;

export(Vector2) var direction := Vector2.LEFT;

func _process(delta: float):
	var collision: KinematicCollision2D = move_and_collide(direction * speed * delta)
	if (collision):
		var tilemap: BricksMap = collision.collider as BricksMap
		tilemap.bricks_hit_at(collision.position)
		direction = direction.bounce(collision.normal)
