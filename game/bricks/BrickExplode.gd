extends Node2D
class_name BrickExplode


onready var brickPartTopLeft = $BrickPartTopLeft
onready var brickPartBottomLeft = $BrickPartBottomLeft
onready var brickPartTopRight = $BrickPartTopRight
onready var brickPartBottomRight = $BrickPartBottomRight

onready var impactTween: Tween = $ImpactTween

var impactDuration: float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func explode(hit_normal: Vector2):
	visible = true
	_build_and_start_impact_tween(hit_normal)
	yield(get_tree().create_timer(0.1), "timeout")
	_push_brick_parts(-1 * hit_normal)


func _build_and_start_impact_tween(hit_normal: Vector2):
	impactTween.remove_all()
	impactTween.interpolate_property(
		self, "position",
		null, position + (hit_normal * -10),
		impactDuration, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	impactTween.start()


func _push_brick_parts(direction: Vector2):
	brickPartTopLeft.start_move(direction.rotated(deg2rad(-60)))
	brickPartBottomLeft.start_move(direction.rotated(deg2rad(-30)))
	brickPartTopRight.start_move(direction.rotated(deg2rad(30)))
	brickPartBottomRight.start_move(direction.rotated(deg2rad(60)))