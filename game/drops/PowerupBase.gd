tool
extends Node2D
class_name PowerupBase


export(float) var fall_rate = 150.0

var should_move = false


func start():
	should_move = true


func _process(delta):
	if should_move:
		position.y += fall_rate * delta



func _on_Area2D_body_entered(body:Node):

	if not body.is_in_group("paddle"):
		return
	
	_paddle_collected_powerup()
	queue_free()


#override to make osmething happen when paddle collects powerup
func _paddle_collected_powerup():
	pass



func _on_screen_exited():
	queue_free()
