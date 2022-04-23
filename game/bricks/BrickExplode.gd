extends Node2D
class_name BrickExplode

onready var impactTween: Tween = $ImpactTween
onready var anim: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func explode(hit_normal: Vector2):
	visible = true
	_build_and_start_impact_tween(hit_normal)
	yield(impactTween, "tween_all_completed")
	anim.play("explode")


func _build_and_start_impact_tween(hit_normal: Vector2):
	impactTween.remove_all()
	impactTween.interpolate_property(
		self, "position",
		null, position + (hit_normal * -10),
		0.25, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	impactTween.start()