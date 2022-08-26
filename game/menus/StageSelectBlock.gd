"""
Single cell in grid of stage selection blocks
shows one brickmap
"""
extends Control

export(PackedScene) var stage_bricks

onready var preview_window: Viewport = $Panel/MarginContainer/VBoxContainer/ViewportContainer/Viewport
onready var stage_title: Label = $Panel/MarginContainer/VBoxContainer/StageTitle


func _ready():
	if stage_bricks:
		var instance = stage_bricks.instance()
		preview_window.add_child(instance)
		_center_in_viewport(preview_window, instance)
	

func _center_in_viewport(viewport: Viewport, bricks: BricksMap):

	var bricks_size = bricks.get_used_rect().size * bricks.cell_size
	var viewport_visible = viewport.get_visible_rect()
	bricks.global_position = Vector2(viewport_visible.position + viewport_visible.size / 2) - bricks_size / 2
