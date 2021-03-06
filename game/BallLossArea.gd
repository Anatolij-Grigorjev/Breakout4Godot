extends Area2D

signal ball_fell(ball)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_BallLossArea_body_exited(body: Node):
	if body.is_in_group("ball"):
		print("ball position %s parent %s" % [body.position, body.get_parent()])
		emit_signal("ball_fell", body)
