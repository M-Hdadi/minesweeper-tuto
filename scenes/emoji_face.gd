class_name  EmojiFace
extends Control
@onready var image: Sprite2D = $Image
@onready var timer: Timer = $Timer

const ANGRY_FACE = 3
const HAPPY_FACE = 2
const NORMAL_FACE = 0
const SCARED_FACE = 1

@export var wait_time := .3

func _ready() -> void:
	image.frame = NORMAL_FACE

	GameState.new_event.connect(_react)
	GameState.game_state_changed.connect(func(game_state: int):
		if game_state == GameState.END_STATE:
			get_tree().create_timer(0.05).timeout.connect(func():
				if GameState.end_minesweeper == GameState.END_LOSE:
					image.frame = ANGRY_FACE
				else:
					image.frame = HAPPY_FACE
			)
		)


func _react(event_id: int, _event_data) -> void:
	if event_id == 1:
		image.frame = SCARED_FACE
		timer.wait_time = wait_time
		timer.start()
		timer.timeout.connect(func():
			if GameState.game_state != GameState.END_STATE:
				image.frame = NORMAL_FACE
			)
