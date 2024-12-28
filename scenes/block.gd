class_name Block
extends Control
@onready var image: Sprite2D = $Image

const CLOSED_VISIBILITY := 12

# visibility values
const CLOSED := 0
const MARKED := 1
const QUESTION := 2
const OPENED := 3

# values
const EMPTY_BLOCK := 0
const MINE_BLOCK := 9
const MINE_EXPLODED := 10
const FALSE_MINE := 11

var value: int = EMPTY_BLOCK:
	get:
		return value
	set(new_value):
		value = new_value
		_update_display()

var visibility: int = CLOSED:
	get:
		return visibility
	set(new_visibility):
		visibility = new_visibility
		_update_display()

func _ready() -> void:
	_update_display()

func _update_display() -> void:
	if image == null:
		return
	if visibility == OPENED:
		image.frame = value
	else:
		image.frame = CLOSED_VISIBILITY + visibility
