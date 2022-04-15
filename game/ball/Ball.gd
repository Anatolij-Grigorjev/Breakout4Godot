extends RigidBody2D
class_name Ball


func _on_Ball_body_shape_entered(body_rid:RID, body:Node, body_shape_index:int, local_shape_index:int):
	print_debug("body_rid=", body_rid.get_id(), " body=", body, " body_shape_index=", body_shape_index, " local_shape_index=", local_shape_index)
	print_debug("Resolved remote collider=", body.shape_owner_get_owner(body_shape_index))
