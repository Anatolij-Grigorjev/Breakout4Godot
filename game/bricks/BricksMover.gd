extends Node2D
class_name BrickMover
"""
mechanism to move around the bricks inside a tilemap without needing other construcitons
allows creating brickmaps that are more dynamic for the breaking
defines aspect of animation in how bricks move around the tilemap

Must be child of brickmap node
"""

onready var brickmap: BricksMap = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
