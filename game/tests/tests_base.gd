# ##############################################################################
# Base class with test related utilities that other test classes can extend
extends "res://addons/gut/test.gd"

var parent: Node2D



######################HELPERS############################

func _setup_tree(nodes: Array):
    parent = Node2D.new()
    for node in nodes:
        parent.add_child(node)
    add_child_autofree(parent)
    _wait_next_frame()


func _wait_seconds(secs: float, message: String = "waiting..."):
    yield(yield_for(secs, message), YIELD)

func _wait_next_frame():
    _wait_seconds(0.16, "waiting for next frame...")