extends Node2D


export(Array, Color) var colorsCycle = [Color.blue, Color.yellow]
export(float) var colorFlashDuration = 0.25
export(float) var totalFloatTime = 1.7
export(String) var text: String = "+100"

onready var colorDurationTimer: Timer = $Duration
onready var ttlTimer: Timer = $TTL
onready var label: Label = $Label

var currentColorIdx = 0

func _ready():
	label.text = text
	colorDurationTimer.wait_time = colorFlashDuration
	ttlTimer.wait_time = totalFloatTime
	ttlTimer.connect("timeout", self, "queue_free")
	colorDurationTimer.connect("timeout", self, "_cycle_next_color")
	_refresh_label_color()
	colorDurationTimer.start()
	ttlTimer.start()



func _cycle_next_color():
	currentColorIdx = (currentColorIdx + 1) % colorsCycle.size()
	_refresh_label_color()


func _refresh_label_color():
	label.modulate = colorsCycle[currentColorIdx]
	
