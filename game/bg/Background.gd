extends Control


onready var pulser: Tween = $Tween
onready var bgTexture = $TextureRect

var base_pulse_duration: float = 0.25


func do_pulse(max_intensity: float):
	pulser.stop_all()
	pulser.remove_all()
	pulser.interpolate_property(
		bgTexture.material, 'shader_param/radius', 
		max_intensity, 0.0, 
		base_pulse_duration * min(2.0, max_intensity), Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	pulser.start() 


func keep_pulsing(intensity: float):
	pulser.repeat = true
	do_pulse(intensity)


func stop_pulsing():
	pulser.repeat = false
