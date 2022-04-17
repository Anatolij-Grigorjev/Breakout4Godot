extends KinematicBody2D
class_name Ball

export(float) var speed: float = 20;

export(Vector2) var direction := Vector2.LEFT;

func _process(delta: float):
	var collision: KinematicCollision2D = move_and_collide(direction * speed * delta)
	if (collision):
		print(collision)
		var tilemap: TileMap = collision.collider as TileMap
		var tileMapIdx = tilemap.world_to_map(tilemap.to_local(collision.position))
		tilemap.set_cellv(tileMapIdx, TileMap.INVALID_CELL)
		direction = direction.bounce(collision.normal)
