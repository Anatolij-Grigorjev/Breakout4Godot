extends Node2D

export(Vector2) var offset = Vector2.ZERO
export(Rect2) var spriteRegion = Rect2(Vector2.ZERO, Vector2.ZERO)

onready var sprite: Sprite = $Sprite
onready var mover: Tween = $Mover

var travelDuration: float = 0.5

func _ready():

	sprite.region_enabled = not spriteRegion.has_no_area()
	sprite.region_rect = spriteRegion
	position = offset


func start_move(path: Vector2):
	mover.remove_all()
	_build_mover_rotation()
	_build_mover_scale()
	_build_mover_travel(path)
	mover.start()
	yield(mover, "tween_all_completed")
	queue_free()


func _build_mover_rotation():
	mover.interpolate_property(
		sprite, "rotation_degrees",
		0, 720, 
		travelDuration, Tween.TRANS_QUAD, Tween.EASE_OUT
	)

func _build_mover_scale():
	mover.interpolate_property(
		sprite, "scale",
		Vector2.ONE, Vector2.ZERO,
		travelDuration, Tween.TRANS_QUAD, Tween.EASE_OUT
	)

func _build_mover_travel(direction: Vector2):
	mover.interpolate_property(
		self, "position",
		null, position + direction * 50,
		travelDuration, Tween.TRANS_QUAD, Tween.EASE_OUT
	)