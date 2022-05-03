extends KinematicBody2D


export(float) var speed: float = 150.0


func _ready():
	pass # Replace with function body.


func _process(delta: float):
	if Input.is_action_pressed("ui_left"):
		position.x -= delta * speed
	if Input.is_action_pressed("ui_right"):
		position.x += delta * speed
