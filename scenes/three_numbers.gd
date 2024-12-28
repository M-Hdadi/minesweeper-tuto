class_name ThreeNumbers
extends Control

@onready var number: Label = $Number

var value := 0:
	get:
		return value
	set(new_value):
		if new_value != value:
			value = clampi(new_value, 0, 999)
			if number:
				number.text = "%03d" % value
