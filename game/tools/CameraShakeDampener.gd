"""
Attach as child to node that is supposed to react to camera shake by a custom amount of own shaking
the shake dampening coefficient describes how much of the shake is compensated by own movements,
where 
0 meaning no dampening - antural shake response, 
1 meaning total compensation - node will stand still while others shake around it
-1 meaning overcompensation by shake amount - node shakes 2x more violently than others around it
"""
extends Node2D
class_name CameraShakeDampener

export(NodePath) var camera_node_path
export(float) var shake_dampen_coef := 1.0


onready var camera_node: Camera2D = get_node(camera_node_path)
onready var target_node = get_parent()


var target_neutral_position: Vector2
var sync_target_with_camera: bool = false


func _ready():
	
	var screen_shake_node = _find_shaker_node_in_camera(camera_node)
	if not screen_shake_node:
		return
	
	screen_shake_node.connect("shake_started", self, "_on_camera_shake_started")
	screen_shake_node.connect("shake_ended", self, "_on_camera_shake_ended")

	target_neutral_position = target_node.position
	sync_target_with_camera = false



func _process(delta: float):
	if sync_target_with_camera:
		target_node.position = target_neutral_position + shake_dampen_coef * camera_node.offset



func _on_camera_shake_started():
	sync_target_with_camera = true
	

func _on_camera_shake_ended():
	sync_target_with_camera = false
	target_node.position = target_neutral_position



func _find_shaker_node_in_camera(camera_node):

	return Utils.getFirst(Utils.getNodeChildrenInGroup(camera_node, "screen_shake"))