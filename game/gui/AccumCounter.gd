tool
extends Control

export(String) var valueTagText: String = "SCORE: "
export(String) var valueFormat: String = "%07d"
export(float) var value: float = 0.0 setget _setValue
export(float) var visualIncrementPerSecond: float = 2000

onready var valueLabel: Label = $HBoxContainer/ValueLabel
onready var tween: Tween = $Tween


func _ready():
	$HBoxContainer/TagLabel.text = valueTagText


func _setValue(newValue: float):
	setTotalValue(newValue)


func setTotalValue(newTotal: float):
	var prevScore: float = value
	value = newTotal
	if ($Tween):
		
		var valueDiffference = abs(value - prevScore)
		var incrementTimeSeconds = valueDiffference / visualIncrementPerSecond
		$Tween.remove_all()
		$Tween.interpolate_method(
			self, "_setLabelTo",
			prevScore, newTotal,
			incrementTimeSeconds, Tween.TRANS_QUAD, Tween.EASE_OUT
		)
		$Tween.start()


func _setLabelTo(newValue: float):
	if ($HBoxContainer/ValueLabel):
		$HBoxContainer/ValueLabel.text = valueFormat % newValue
