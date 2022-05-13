extends TileMap
class_name BricksMap

signal brickDestroyed(brickType, brickPos)
signal map_cleared(num_bricks)


const BrickBoomScn = preload("res://bricks/BrickExplode.tscn")

var animations_cache = {}
var total_num_bricks: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	total_num_bricks = get_used_cells().size()
	for tileIdx in get_used_cells():
		animations_cache[tileIdx] = _build_hidden_boom_at_tile_idx(tileIdx)
	


func bricks_hit_at(global_hit_pos: Vector2, hit_normal: Vector2):
	var tileIdx: Vector2 = world_to_map(to_local(global_hit_pos))
	print("global pos: " + String(global_hit_pos) + " tileidx: " + String(tileIdx) + " tile type: " + String(get_cellv(tileIdx)))
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
	#world coordinate holds top left corner of cell position
	# origin of exploding animation is center of cell, so adding offset
	brickBoomNode.position = map_to_world(idx) + cell_size / 2
	return brickBoomNode


func _check_all_cells_empty() -> bool:
	return get_used_cells().empty()