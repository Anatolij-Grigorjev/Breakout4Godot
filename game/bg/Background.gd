extends Control


onready var pulser: Tween = $Tween
onready var bgTexture = $TextureRect

func _ready():
	pass # Replace with function body.


func do_pulse(max_intensity: float):
	pulser.stop_all()
	pulser.remove_all()
	pulser.interpolate_property(
		bgTexture.material, 'shader_param/radius', 
		max_intensity, 0.0, 
		0.25, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	pulser.start() 
