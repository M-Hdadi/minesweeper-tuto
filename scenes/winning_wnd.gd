extends Control

@onready var _message: Label = $Message
@onready var _replay: Button = $Replay
@onready var _close: Button = $Close

const _messages := [
"New best time!\nYou’ve shattered your\nprevious record!",
"Amazing!\nYou’ve beaten your\nsecond-best time!",
"Incredible!\nYou’ve just broken\nyour third-best record!",
"Congratulations!\nYou cleared the minefield\nwithout hitting any bombs.\nMasterful play!"]
var _message_id := 3:
	get:
		return _message_id
	set(new_message_id):
		if new_message_id != _message_id && new_message_id >= 0 && new_message_id < 4:
			_message_id = new_message_id
			if _message:
				_message.text = _messages[_message_id]

func _ready() -> void:
	GameState.game_state_changed.connect(func(game_state: int):
		if game_state == GameState.END_STATE && GameState.end_minesweeper == GameState.END_WIN:
			GameState.emit_event(GameState.OPEN_WINNING_ID, null)
		)
	
	_close.pressed.connect(func():
		GameState.emit_event(GameState.CLOSE_WND_ID, null)
		get_tree().create_timer(1.0).timeout.connect(func(): _message_id = 3)
		)
	_replay.pressed.connect(func():
		GameState.emit_event(GameState.CLOSE_WND_ID, null)
		get_tree().create_timer(0.4).timeout.connect(func():
			GameState.start()
			_message_id = 3
			)
		)
	Scores.new_score.connect(func(_size_id: int, index: int):
		_message_id = index
		)
