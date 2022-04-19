extends TileMap
class_name BricksMap

const BrickBoomScn = preload("res://bricks/BrickExplode.tscn")

var animations_cache = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for tileIdx in get_used_cells():
		animations_cache[tileIdx] = _build_hidden_boom_at_tile_idx(tileIdx)
	



func bricks_hit_at(global_hit_pos: Vector2):
	var tileIdx: Vector2 = world_to_map(to_local(global_hit_pos))
	print("global pos: " + String(global_hit_pos) + " tileidx: " + String(tileIdx) + " tile type: " + String(get_cellv(tileIdx)))
	var tileTypeAtPos = get_cellv(tileIdx)
	if (tileTypeAtPos != TileMap.INVALID_CELL):
		set_cellv(tileIdx, TileMap.INVALID_CELL)
		var explosion = animations_cache[tileIdx]
		explosion.explode()
	


func _build_hidden_boom_at_tile_idx(idx: Vector2) -> Node2D:
	var brickBoomNode: Node2D = BrickBoomScn.instance()
	add_child(brickBoomNode)
	brickBoomNode.visible = false
	#world coordinate holds top left corner of cell position
	# origin of exploding animation is center of cell, so adding offset
	brickBoomNode.position = map_to_world(idx) + cell_size / 2
	return brickBoomNode
