"""
Single cell in grid of stage selection blocks
shows one brickmap
"""
extends Control

export(PackedScene) var stage_bricks
export(String) var stage_title setget _set_title_label

onready var preview_window: Viewport = $Panel/MarginContainer/VBoxContainer/ViewportContainer/Viewport
onready var stage_title_lbl: Label = $Panel/MarginContainer/VBoxContainer/StageTitle
onready var placeholder_graphic: TextureRect = $Panel/MarginContainer/VBoxContainer/ViewportContainer/Viewport/LockedTexture


func _ready():
	_set_title_label(stage_title)
	if not stage_bricks:
		return
	var instance = stage_bricks.instance()
	placeholder_graphic.queue_free()
	preview_window.add_child(instance)
	call_deferred("_center_in_viewport", preview_window, instance)
	

func _center_in_viewport(viewport: Viewport, bricks: BricksMap):

	var scale_factor = _get_bricks_scale_factor(viewport, bricks)
	var bricks_orig_size = bricks.get_used_rect().size * bricks.cell_size
	var bricks_size = bricks_orig_size * scale_factor
	var viewport_size = viewport.get_visible_rect().size
	bricks.scale *= scale_factor
	bricks.global_position = viewport_size / 2 - bricks_size / 2
	#aligned to vertical top
	bricks.global_position.y = 10
	print("bricks_orig_size=%s|\nscale_factor=%s|\nbricks_size=%s|\nviewport_size=%s|\nbricks_pos=%s|" % [
		bricks_orig_size, scale_factor, bricks_size, viewport_size, bricks.global_position
	])


func _get_bricks_scale_factor(viewport: Viewport, bricks: BricksMap) -> float:
	var viewport_size = viewport.get_visible_rect().size
	var bricks_size = bricks.get_used_rect().size * bricks.cell_size

	return min(viewport_size.x / bricks_size.x, viewport_size.y / bricks_size.y)



func _set_title_label(title: String):
	stage_title = title
	var lbl = $Panel/MarginContainer/VBoxContainer/StageTitle
	if lbl:
		lbl.text = title
