extends TileMap
class_name BricksMap

const BrickBoomScn = preload("res://bricks/BrickExplode.tscn")

var animations_cache = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for tileIdx in get_used_cells():
		animations_cache[tileIdx] = _build_hidden_boom_at_tile_idx(tileIdx)
	



func bricks_hit_at(global_hit_pos: Vector2):
	var tileIdx = world_to_map(to_local(global_hit_pos))
	set_cellv(tileIdx, TileMap.INVALID_CELL)
	var animation = animations_cache[tileIdx]
	animation.visible = true
	animation.get_node("AnimationPlayer").play("explode")
	


func _build_hidden_boom_at_tile_idx(idx: Vector2) -> Node2D:
	var brickBoomNode: Node2D = BrickBoomScn.instance()
	add_child(brickBoomNode)
	brickBoomNode.visible = false
	brickBoomNode.position = map_to_world(idx) + cell_size / 2
	return brickBoomNode
