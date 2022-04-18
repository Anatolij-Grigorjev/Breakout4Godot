extends Node2D
class_name BrickExplode


onready var anim: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func explode():
	visible = true
	anim.play("explode")

