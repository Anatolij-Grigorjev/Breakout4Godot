extends Node2D


const SHOUT_TRAVEL_BASE = 20

var text: String
var direction: Vector2 = Vector2.ZERO

onready var tween: Tween = $Tween


func _ready():
	$Sprite/Label.text = text
	var shout_travel_amount = SHOUT_TRAVEL_BASE * rand_range(0.8, 1.2)
	tween.interpolate_property(
		$Sprite, 'position', 
		Vector2.ZERO, Vector2.ONE * shout_travel_amount,
		0.3, 
		Tween.TRANS_QUART, Tween.EASE_OUT
	)
	tween.start()



func _set_label_text(new_text: String) -> void:
	if ($Sprite/Label):
		$Sprite/Label.text = new_text


