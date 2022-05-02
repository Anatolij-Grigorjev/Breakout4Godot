extends Node2D


export(Array, Color) var colorsCycle = [Color.blue, Color.yellow]
export(float) var colorFlashDuration = 0.16
export(float) var totalFloatTime = 1.0
export(float) var pointsRaiseHeight: float = 25.5
export(String) var text: String = "+100"

onready var colorDurationTimer: Timer = $Duration
onready var ttlTimer: TTL = $TTL
onready var label: Label = $Label
onready var tween: Tween = $Tween

var currentColorIdx = 0

func _ready():
	label.text = text
	colorDurationTimer.wait_time = colorFlashDuration
	ttlTimer.wait_time = totalFloatTime
	colorDurationTimer.connect("timeout", self, "_cycle_next_color")
	_refresh_label_color()
	colorDurationTimer.start()
	ttlTimer.start()
	_start_raise_tween()



func _cycle_next_color():
	currentColorIdx = (currentColorIdx + 1) % colorsCycle.size()
	_refresh_label_color()


func _refresh_label_color():
	label.modulate = colorsCycle[currentColorIdx]


func _start_raise_tween():
	tween.interpolate_property(
		self, "position",
		null, position - Vector2(0, pointsRaiseHeight),
		totalFloatTime * 0.8, 
		Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	tween.start() 
	
