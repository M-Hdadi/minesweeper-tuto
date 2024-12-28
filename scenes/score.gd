class_name Score
extends Control

@onready var _date: Label = $Date
@onready var _second: Label = $Second

func set_score(date: String, second: String) -> void:
	if _date && _second:
		if date:
			_date.text = date
		if second:
			_second.text = second
