tool
extends Node2D

export(String) var scoreFormat: String = "%07d"
export(float) var score: float = 0.0 setget _setScore

onready var label: Label = $Label


func _ready():
	pass # Replace with function body.


func _setScore(value: float):
	score = value
	if ($Label):
		$Label.text = scoreFormat % score
