extends Node

signal second(sec : int)

var _time := 0.0
var _running := false
var _last_second := 0

func _ready() -> void:
	GameState.game_state_changed.connect(new_game_state)

func _process(delta: float) -> void:
	if !_running: return
	_time += delta
	if _time >= _last_second:
		_last_second += 1
		second.emit(_last_second)

func start() -> void:
	if !_running:
		_running = true
		second.emit(_last_second)

func stop() -> void:
	if _running:
		_running = false

func restart() -> void:
	reset()
	start()

func reset() -> void:
	_running = false
	_time = 0.0
	_last_second = 0

func new_game_state(game_state: int) -> void:
	match game_state:
		GameState.START_STATE:
			reset()
		GameState.PLAY_STATE:
			restart()
		GameState.END_STATE:
			stop()
