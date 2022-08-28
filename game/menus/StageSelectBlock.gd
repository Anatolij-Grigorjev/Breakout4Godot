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
		call_deferred("_center_in_viewport", preview_window, instance)
	

func _center_in_viewport(viewport: Viewport, bricks: BricksMap):

	var scale_factor = _get_bricks_scale_factor(viewport, bricks)
	var bricks_orig_size = bricks.get_used_rect().size * bricks.cell_size
	var bricks_size = bricks_orig_size * scale_factor
	var viewport_size = viewport.get_visible_rect().size
	bricks.scale *= scale_factor
	bricks.global_position = viewport_size / 2 - bricks_size / 2
	print("bricks_orig_size=%s|\nscale_factor=%s|\nbricks_size=%s|\nviewport_size=%s|\nbricks_pos=%s|" % [
		bricks_orig_size, scale_factor, bricks_size, viewport_size, bricks.global_position
	])


func _get_bricks_scale_factor(viewport: Viewport, bricks: BricksMap) -> float:
	var viewport_size = viewport.get_visible_rect().size
	var bricks_size = bricks.get_used_rect().size * bricks.cell_size

	return min(viewport_size.x / bricks_size.x, viewport_size.y / bricks_size.y)
