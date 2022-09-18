extends Control



onready var timer = $Timer
onready var anim = $AnimationPlayer

onready var bricks = [
	$RotatingBrick,
	$RotatingBrick2,
	$RotatingBrick3,
	$RotatingBrick4
]

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.autostart = false
	timer.one_shot = true
	timer.connect("timeout", self, "_on_pulsetime_end")


func do_speed_pulse(duration: float, speedup: float = 2.0):
	anim.playback_speed = max(2.0, speedup)
	for brick in bricks:
		brick.get_node("Sprite").modulate.r = 0.9
	_start_timer_for(duration)


func _start_timer_for(duration: float):
	timer.stop()
	timer.wait_time = duration
	timer.start()


func _on_pulsetime_end():
	for brick in bricks:
		brick.get_node("Sprite").modulate.r = 0.0
	anim.playback_speed = 1.0
