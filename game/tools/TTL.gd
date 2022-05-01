"""
A kind of timer that will free() its immediate parent when its done running
"""
extends Timer
class_name TTL

onready var parent = get_parent()

func _ready():
	one_shot = true
	connect("timeout", parent, "queue_free")
