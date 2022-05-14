extends Node2D


onready var mult_Lbl: Label = $HBoxContainer/MultiplierLbl


var ball


func _ready():
	var ballsInTree = get_tree().get_nodes_in_group("ball")
	if not ballsInTree.empty():
		ball = ballsInTree[0]
	

func _process(delta):
	if (ball):
		mult_Lbl.text = "%s" % (ball.currentSpeed / ball.baseSpeed)
