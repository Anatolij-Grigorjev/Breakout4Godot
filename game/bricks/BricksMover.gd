extends Node2D
class_name BrickMover
"""
mechanism to move around the bricks inside a tilemap without needing other construcitons
allows creating brickmaps that are more dynamic for the breaking
defines aspect of animation in how bricks move around the tilemap
Bricks will not move into occupied positions, nor will anything move if the intended brick is broken

Must be child of brickmap node
"""
enum CHANGES {
	CYCLE = 0,
	BOUNCE = 1,
	SEQUENCE = 2
}

# keys should be vector2 positions within brickmap
# the values should be lists of Vector2 positions to be 
# used in the movement of the brick. First position should be same as key. 
# Ex:
# {
#	(0;0): [(0;0), (0;1), (0;2)]
# }
#
export(Dictionary) var brick_positions_sequences := {} 
export(CHANGES) var positions_change_mode = CHANGES.CYCLE
export(float) var position_time := 1.0

onready var brickmap: BricksMap = get_parent()
onready var timer = $Timer

var cycles_steps = {}


func _ready():

	_reset_cycle_positions()
	_configure_timer()
	if brick_positions_sequences:
		timer.start()


func _reset_cycle_positions():
	for brick_pos in brick_positions_sequences:
		cycles_steps[brick_pos] = 0


func _configure_timer():
	timer.one_shot = false
	timer.wait_time = position_time
	timer.connect("timeout", self, "_on_frametime_end")




func _on_frametime_end():
	# advance positions
	for brick_initial_pos in brick_positions_sequences:
		var sequence = brick_positions_sequences[brick_initial_pos]
		var cycle_pos = cycles_steps[brick_initial_pos]

		_advance_cycle_positions(brick_initial_pos, sequence, cycle_pos)


func _advance_cycle_positions(brick_initial_pos: Vector2, sequence: Array, cycle_pos: int):

	var current_tile_pos = sequence[cycle_pos]
	var current_tile_type = brickmap.get_cellv(current_tile_pos)
	if current_tile_type == TileMap.INVALID_CELL:
		return

	var next_pos = cycle_pos + 1
	# advancing through some middle positions - just advance
	if sequence.size() > next_pos:
		var new_position = sequence[next_pos]
		brickmap.set_cellv(new_position, current_tile_type)
	#final position, change mode determines where they go from here
	elif sequence.size() == next_pos:
		#for now just alwasy cycle
		cycles_steps[brick_initial_pos] = 0
		brickmap.set_cellv(brick_initial_pos, current_tile_type)