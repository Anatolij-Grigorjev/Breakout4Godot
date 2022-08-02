tool
extends Node2D
class_name PowerupBase


signal drop_collected()

export(float) var fall_rate = 150.0

var should_move = false


func start_in_stage(game_stage):
	should_move = true
	game_stage.add_child(self)
	connect("drop_collected", game_stage, "_on_paddle_collected_drop")



func _process(delta):
	if should_move:
		position.y += fall_rate * delta



func _on_Area2D_body_entered(body: Node2D):

	if not body.is_in_group("paddle"):
		return
	
	emit_signal("drop_collected")

	_paddle_collected_powerup()
	queue_free()


#override to make osmething happen when paddle collects powerup
func _paddle_collected_powerup():
	pass



func _on_screen_exited():
	queue_free()
