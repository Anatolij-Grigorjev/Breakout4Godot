extends KinematicBody2D
class_name Ball

export(float) var speed: float = 20;

export(Vector2) var direction := Vector2.LEFT;

func _process(delta: float):
	var collision: KinematicCollision2D = move_and_collide(direction * speed * delta)
	if (collision):
		print(dumpObjectAllProperties(collision))
		var tilemap: TileMap = collision.collider as TileMap
		var tileMapIdx = tilemap.world_to_map(collision.position)
		tilemap.set_cellv(tileMapIdx, TileMap.INVALID_CELL)
		direction = direction.bounce(collision.normal)



static func dumpObjectAllProperties(object: Object) -> String:
	var currentPropValues := ["<%s>" % object.get_class()]
	for prop in object.get_property_list():
		currentPropValues.append("\t%s=%s" % [prop.name, object.get(prop.name)])
	currentPropValues.append("</%s>" % object.get_class())	
	return joinToString(currentPropValues, "\n")


"""
Join elements of an Array as a string  using the 
'joiner' delimiter.
Each element is stringified using the 'formatter' format string.
"""
static func joinToString(
	col: Array, joiner = ",", formatter: String = "%s"
) -> String:
	var stringPool := PoolStringArray()
	for item in col:
		stringPool.append(formatter % item)
	return stringPool.join(joiner)
