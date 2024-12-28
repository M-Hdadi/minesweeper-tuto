extends Node

signal game_state_changed(new_game_state: int)
signal new_event(event_id: int, event_data)

const CLOSE_WND_ID := 3
const OPEN_SETTINGS_ID := 4
const OPEN_SCORES_ID := 10
const OPEN_WINNING_ID := 11

const START_STATE := 0
const PLAY_STATE := 1
const PAUSE_STATE := 2
const END_STATE := 3

const END_WIN := 1
const END_LOSE := 2

var end_minesweeper: int

var game_state := START_STATE

func play() -> void:
	if game_state == START_STATE:
		game_state = PLAY_STATE
		_emit_signal()

func end() -> void:
	if game_state == PLAY_STATE || game_state == PAUSE_STATE:
		game_state = END_STATE
		_emit_signal()

func start() -> void:
	game_state = START_STATE
	_emit_signal()

func pause() -> void:
	if game_state == PLAY_STATE:
		game_state = PAUSE_STATE
		_emit_signal()

func resume() -> void:
	if game_state == PAUSE_STATE:
		game_state = PLAY_STATE
		_emit_signal()

func _emit_signal() -> void:
	game_state_changed.emit(game_state)

func emit_event(event_id: int, event_data) -> void:
	new_event.emit(event_id, event_data)
