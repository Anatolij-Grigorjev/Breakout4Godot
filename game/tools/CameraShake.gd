extends Node2D
"""
An action that can be attached to a given Camera2D to perform 
screen shake on-demand
"""
const TRANSITION = Tween.TRANS_SINE
const EASING = Tween.EASE_OUT_IN

signal onShakeEnded

var amplitude = 0
var priority = 0

onready var camera: Camera2D = get_parent()


func beginShake(duration = 0.2, frequency = 15, amplitude = 10, priority = 1):
	_onCameraShakeRequested(duration, frequency, amplitude, priority)


func _newShake():
	var randOffset = Utils.randomPoint(amplitude, amplitude)
	_startInterpolateCameraOffset(randOffset)


func _reset():
	priority = 0
	call_deferred("_resetCamera")


func _onFrequencyTimeout():
	_newShake()


func _onDurationTimeout():
	$Frequency.stop()
	emit_signal("onShakeEnded")
	_reset()
	


func _onCameraShakeRequested(duration = 0.2, frequency = 15, amplitude = 10, priority = 1):
	if (priority < self.priority):
		return
	
	self.amplitude = amplitude
	self.priority = priority
	$Duration.wait_time = duration
	$Frequency.wait_time = 1 / float(frequency)
	$Duration.start()
	$Frequency.start()
	
	_newShake()
	
	
func _resetCamera():
	_startInterpolateCameraOffset(Vector2.ZERO)
	
	

func _startInterpolateCameraOffset(targetOffset: Vector2):
	$ShakeTween.interpolate_property(
		camera, 'offset', 
		camera.offset, targetOffset, 
		$Frequency.wait_time, TRANSITION, EASING
	)
	$ShakeTween.start()
