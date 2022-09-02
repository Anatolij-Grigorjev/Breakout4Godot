"""
Single cell in grid of stage selection blocks
shows one brickmap
"""
extends Control

const BallScn = preload("res://ball/Ball.tscn")
const SelectPaddleScn = preload("res://menus/SelectStagePaddle.tscn")

export(PackedScene) var stage_bricks
export(Vector2) var ball_position = Vector2.ZERO
export(String) var stage_title setget _set_title_label

onready var preview_window: Viewport = $Panel/MarginContainer/VBoxContainer/ViewportContainer/Viewport
onready var stage_title_lbl: Label = $Panel/MarginContainer/VBoxContainer/StageTitle
onready var placeholder_graphic: TextureRect = $Panel/MarginContainer/VBoxContainer/ViewportContainer/Viewport/LockedTexture

onready var barrier_left = $Panel/MarginContainer/VBoxContainer/ViewportContainer/Viewport/BarrierLeft
onready var barrier_right = $Panel/MarginContainer/VBoxContainer/ViewportContainer/Viewport/BarrierRight
onready var barrier_top = $Panel/MarginContainer/VBoxContainer/ViewportContainer/Viewport/BarrierTop
onready var barrier_bottom = $Panel/MarginContainer/VBoxContainer/ViewportContainer/Viewport/BarrierBottom

var bricks: BricksMap
var ball: Ball
var elements_scale_factor: float = 1.0

var stage_focused = false

func _ready():
	#create duplicate of own style when several instances present and animation is possible
	$Panel.set("custom_styles/panel", $Panel.get("custom_styles/panel").duplicate(true))
	#center pivot for scale animations
	$Panel.rect_pivot_offset = $Panel.rect_size / 2

	_set_title_label(stage_title)
	if not stage_bricks:
		return
	$TouchPanel.connect("mouse_entered", self, "_on_Panel_mouse_entered")
	$TouchPanel.connect("mouse_exited", self, "_on_Panel_mouse_exited")
	bricks = stage_bricks.instance()
	placeholder_graphic.queue_free()
	preview_window.add_child(bricks)
	call_deferred("_center_in_viewport", preview_window, bricks)
	call_deferred("_position_barriers_in_viewport", preview_window)
	

func _center_in_viewport(viewport: Viewport, bricks: BricksMap):

	elements_scale_factor = _get_bricks_scale_factor(viewport, bricks)
	var bricks_orig_size = bricks.get_used_rect().size * bricks.cell_size
	var bricks_size = bricks_orig_size * elements_scale_factor
	var viewport_size = viewport.get_visible_rect().size
	bricks.scale *= elements_scale_factor
	bricks.global_position = viewport_size / 2 - bricks_size / 2
	#aligned to vertical top
	bricks.global_position.y = 10


func _position_barriers_in_viewport(viewport: Viewport):
	var viewport_size = viewport.get_visible_rect().size
	#place barriers
	barrier_left.position.x = -10
	barrier_top.position.y = -10
	barrier_right.position.x = viewport_size.x + 10
	barrier_bottom.position.y = viewport_size.y + 10


func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and stage_focused:
		_select_stage()


func _clear_ball():
	if is_instance_valid(ball):
		ball.queue_free()


func _reset_view():
	_clear_ball()
	yield(get_tree(), "idle_frame")
	bricks.reset_bricks()


func _launch_ball():
	_clear_ball()
	ball = BallScn.instance()
	preview_window.add_child(ball)
	ball.scale *= elements_scale_factor
	ball.position = ball_position
	ball.direction = Utils.randomPoint(1.0, 1.0)
	ball.speedup_ball_by_amount(ball.speed_additive_for_coef(5.0))
	


func _get_bricks_scale_factor(viewport: Viewport, bricks: BricksMap) -> float:
	var viewport_size = viewport.get_visible_rect().size
	var bricks_size = bricks.get_used_rect().size * bricks.cell_size

	#slightly smaller than viewport
	return min(viewport_size.x / bricks_size.x, viewport_size.y / bricks_size.y) * 0.9



func _set_title_label(title: String):
	stage_title = title
	var lbl = $Panel/MarginContainer/VBoxContainer/StageTitle
	if lbl:
		lbl.text = title


func _on_Panel_mouse_entered():
	stage_focused = true
	$AnimationPlayer.queue("hover")
	if not is_instance_valid(ball):
		_launch_ball()

func _on_Panel_mouse_exited():
	stage_focused = false
	$AnimationPlayer.queue("unfocus")
	if is_instance_valid(ball):
		_reset_view()


func _select_stage():
	var paddle = _fire_selection_paddle()
	$AnimationPlayer.play("select")

	yield(paddle.get_node("AnimationPlayer"), "animation_finished")
	print("Stage selected! This one: %s" % self.stage_title)


func _fire_selection_paddle() -> Node2D:
	var paddle = SelectPaddleScn.instance()
	preview_window.add_child(paddle)
	paddle.scale *= elements_scale_factor
	var viewport_size = preview_window.get_visible_rect().size
	paddle.position = Vector2(viewport_size.x / 2, viewport_size.y - 20)

	return paddle
