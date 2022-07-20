tool
extends Node2D


signal points_collected(amount)

export(float) var fall_rate = 150.0
export(float) var points_amount = 5000 setget _set_bonus_points


var should_move = false



func start():
	should_move = true


func _process(delta):
	if should_move:
		position.y += fall_rate * delta



func _on_Area2D_body_entered(body:Node):

	if not body.is_in_group("paddle"):
		return
	
	emit_signal("points_collected", points_amount)
	queue_free()


func _set_bonus_points(new_amount: float):
	points_amount = new_amount
	if $Sprite/AmountLbl:
		$Sprite/AmountLbl.text = "+%d" % points_amount



func _on_screen_exited():
	queue_free()
