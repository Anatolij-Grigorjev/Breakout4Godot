tool
extends Node2D

export(String) var scoreFormat: String = "%07d"
export(float) var score: float = 0.0 setget _setValue

onready var valueLabel: Label = $HBoxContainer/ValueLabel
onready var tween: Tween = $Tween


func _ready():
	pass


func _setValue(value: float):
	setTotalValue(value)


func setTotalValue(newTotal: float):
	var prevScore: float = score
	score = newTotal
	if ($Tween):
		$Tween.remove_all()
		$Tween.interpolate_method(
			self, "_setLabelTo",
			prevScore, newTotal,
			0.5, Tween.TRANS_QUAD, Tween.EASE_OUT
		)
		$Tween.start()


func _setLabelTo(value: float):
	if ($HBoxContainer/ValueLabel):
		$HBoxContainer/ValueLabel.text = scoreFormat % value
