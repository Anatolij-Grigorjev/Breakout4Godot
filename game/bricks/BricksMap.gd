extends TileMap
class_name BricksMap

const BrickBoomScn = preload("res://bricks/BrickExplode.tscn")


signal brick_destroyed(ball, brickType, brickPos)
signal brick_damaged(brick_pos, hit_type, new_type)
signal map_cleared(num_bricks)
signal bricks_appeared

export(Dictionary) var brick_type_transitions = {
	"1": [0],
	"0": [-1]
}

onready var battery: ParticlesBattery = $ParticlesBattery
onready var timer: Timer = $Timer


var types_transition_map = {}
var total_num_bricks: int = 0

#map of bricks positions to bricks before anything is destroyed
var initial_bricks_snapshot = {}


func _ready():
	#any brickmap is in bricks group
	add_to_group("bricks")

	total_num_bricks = get_used_cells().size()
	#replace arrays with "fun" wrappers
	for type in brick_type_transitions:
		types_transition_map[type.to_int()] = ArrayFunRandom.new(brick_type_transitions[type], -1)
	#build initial snapshot
	for cell_idx in get_used_cells():
		initial_bricks_snapshot[cell_idx] = get_cellv(cell_idx)
	
	

func _process(delta):
	if Input.is_action_just_released("debug1"):
		var first_used_cell = get_used_cells()[0]
		var rand_normal = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
		_hit_brick_at_idx_by_ball(Utils.getFirstTreeNodeInGroup(get_tree(), "ball"), first_used_cell, rand_normal)
	if Input.is_action_just_released("debug2"):
		reapper_bricks()	


func bricks_hit_at_by_ball(ball, global_hit_pos: Vector2, hit_normal: Vector2):
	var tile_idx: Vector2 = world_to_map(to_local(global_hit_pos))
	_hit_brick_at_idx_by_ball(ball, tile_idx, hit_normal)


const MAX_NUM_BLINKS = 10
func reapper_bricks():
	_clear_bricks()
	var random_positions = initial_bricks_snapshot.keys().duplicate()
	random_positions.shuffle()
	var bricks_per_blink = random_positions.size() / MAX_NUM_BLINKS
	for idx in range(0, random_positions.size(), bricks_per_blink):
		for iter_idx in range(idx, idx + bricks_per_blink):
			if iter_idx < random_positions.size():
				var saved_pos = random_positions[iter_idx]
				battery.fireNextParticleSystem(to_global(map_to_world(saved_pos) + cell_size / 2))
				set_cellv(saved_pos, Utils.nvl(initial_bricks_snapshot[saved_pos], INVALID_CELL))
		timer.start()
		yield(timer, "timeout")
	emit_signal("bricks_appeared")


func reset_bricks():
	for saved_pos in initial_bricks_snapshot:
		set_cellv(saved_pos, Utils.nvl(initial_bricks_snapshot[saved_pos], INVALID_CELL))


func _clear_bricks():
	clear()
	

func _hit_brick_at_idx_by_ball(ball, tile_idx: Vector2, hit_normal: Vector2):
	var tile_type_at_idx = get_cellv(tile_idx)
	if (tile_type_at_idx == TileMap.INVALID_CELL):
		return
	
	var next_brick_type = _get_next_brick_type(tile_type_at_idx)
	_build_hidden_boom_at_tile_idx(tile_idx).explode(hit_normal)
	if next_brick_type == TileMap.INVALID_CELL:
		emit_signal("brick_destroyed", ball, tile_type_at_idx, tile_idx)
	else:
		emit_signal("brick_damaged", tile_idx, tile_type_at_idx, next_brick_type)

	yield(get_tree().create_timer(0.1), "timeout")
	set_cellv(tile_idx, next_brick_type)
	_check_and_emit_if_grid_empty()


func _get_next_brick_type(current_type: int) -> int:
	var fun_array = types_transition_map[current_type] as ArrayFunRandom
	var next_random_type = fun_array.get_fun_random()

	return Utils.nvl(next_random_type, -1)


func _build_hidden_boom_at_tile_idx(tile_idx: Vector2) -> Node2D:
	var brick_boom_node: Node2D = BrickBoomScn.instance()
	add_child(brick_boom_node)
	brick_boom_node.visible = false
	brick_boom_node.show_behind_parent = true
	# world coordinate holds top left corner of cell position
	#  origin of exploding animation is center of cell, so adding offset
	brick_boom_node.position = map_to_world(tile_idx) + cell_size / 2
	return brick_boom_node


func _check_and_emit_if_grid_empty():
	var map_cleared = _check_all_cells_empty()
	if map_cleared:
		emit_signal("map_cleared", total_num_bricks)


func _check_all_cells_empty() -> bool:
	return get_used_cells().empty()
