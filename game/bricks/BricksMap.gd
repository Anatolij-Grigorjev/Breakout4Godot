extends TileMap
class_name BricksMap

const BrickBoomScn = preload("res://bricks/BrickExplode.tscn")


signal brickDestroyed(brickType, brickPos)
signal map_cleared(num_bricks)


export(Dictionary) var pointsForBrickOfType = { 
	0: 540.0 
}


var animations_cache = {}
var total_num_bricks: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	total_num_bricks = get_used_cells().size()
	for tileIdx in get_used_cells():
		animations_cache[tileIdx] = _build_hidden_boom_at_tile_idx(tileIdx)
	

func _process(delta):
	if Input.is_action_just_released("debug1"):
		var first_used_cell = get_used_cells()[0]
		var rand_normal = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
		_hit_brick_at_idx(first_used_cell, rand_normal)


func get_points_for_brick_type(type: int) -> float:
	return pointsForBrickOfType[type]


func bricks_hit_at(global_hit_pos: Vector2, hit_normal: Vector2):
	var tileIdx: Vector2 = world_to_map(to_local(global_hit_pos))
	_hit_brick_at_idx(tileIdx, hit_normal)
	

func _hit_brick_at_idx(tileIdx: Vector2, hit_normal: Vector2):
	var tileTypeAtPos = get_cellv(tileIdx)
	if (tileTypeAtPos != TileMap.INVALID_CELL):
		set_cellv(tileIdx, TileMap.INVALID_CELL)
		var explosion = animations_cache[tileIdx]
		explosion.explode(hit_normal)
		emit_signal("brickDestroyed", tileTypeAtPos, tileIdx)
		var map_cleared = _check_all_cells_empty()
		if map_cleared:
			emit_signal("map_cleared", total_num_bricks)


func _build_hidden_boom_at_tile_idx(idx: Vector2) -> Node2D:
	var brickBoomNode: Node2D = BrickBoomScn.instance()
	add_child(brickBoomNode)
	brickBoomNode.visible = false
	# world coordinate holds top left corner of cell position
	#  origin of exploding animation is center of cell, so adding offset
	brickBoomNode.position = map_to_world(idx) + cell_size / 2
	return brickBoomNode


func _check_all_cells_empty() -> bool:
	return get_used_cells().empty()
