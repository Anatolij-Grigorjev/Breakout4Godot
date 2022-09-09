extends Control


onready var tween = $Tween
onready var stages_container = $Panel/MarginContainer/VBoxContainer/GridContainer

func _ready():
	for stage in stages_container.get_children():
		stage.connect("selected_stage_ready", self, "_on_stage_selection_ready")


func _on_stage_selection_ready(stage: Control):
	_start_fade_all_except(stage)
	_tween_stage_to_center(stage)
	yield(tween, "tween_all_completed")
	_tween_stage_to_size(stage)
	yield(tween, "tween_all_completed")
	$FadeToBlack/AnimationPlayer.play("fade_to_black")


func _start_fade_all_except(exception: Control):
	for stage in stages_container.get_children():
		if (stage != exception):
			stage.anim.play("fade")


func _tween_stage_to_center(stage: Control):
	tween.interpolate_property(
		stage, "rect_position",
		null, stages_container.rect_size / 2 - stage.get_rect().size / 2,
		0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	tween.start()

func _tween_stage_to_size(stage: Control):
	stage.rect_pivot_offset = stage.rect_size / 2
	tween.interpolate_property(
		stage, "rect_scale",
		null, Vector2(10, 10),
		0.5, Tween.TRANS_QUAD, Tween.EASE_IN,
		0.5
	)
	tween.start()
