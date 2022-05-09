tool
extends Node2D

const ExtraBallScn = preload("res://gui/ExtraBallImage.tscn")


export(int) var numExtraBalls = 3 setget _setNumBalls

onready var ballsContainer = $HBoxContainer


func _ready():
	_reset_visible_balls(numExtraBalls)




func _setNumBalls(newBallsNum: int):
	numExtraBalls = clamp(newBallsNum, 0, newBallsNum)
	if ($HBoxContainer):
		_reset_visible_balls(numExtraBalls)



func _reset_visible_balls(numBalls: int):
	var container = $HBoxContainer
	var currentBalls = container.get_children()
	var currentNum = currentBalls.size()
	if numBalls > currentNum:
		for _idx in range(numBalls - currentNum):
			var newBall = ExtraBallScn.instance()
			container.add_child(newBall)
	if numBalls < currentNum:
		for idx in range(numBalls, currentNum):
			currentBalls[idx].queue_free()

