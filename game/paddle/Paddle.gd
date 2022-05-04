extends KinematicBody2D


export(float) var speed: float = 150.0


func _ready():
	pass # Replace with function body.


func _process(delta: float):
	var direction = Vector2(0, 0)
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	
	move_and_collide(direction * speed * delta)

