extends Node

signal  new_score(size_id: int, index: int)

const _SCORES_PATH := "user://scores.cfg"

var scores_table := [[[100000, "2024-12-26"],[100000, "2024-12-26"],[100000, "2024-12-26"]],
[[100000, "2024-12-26"],[100000, "2024-12-26"],[100000, "2024-12-26"]],
[[100000, "2024-12-26"],[100000, "2024-12-26"],[100000, "2024-12-26"]]]

var _is_scores_loaded := false
var _scores := ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_scores()
	GameState.game_state_changed.connect(func(new_game_state: int):
		if new_game_state == GameState.END_STATE and GameState.end_minesweeper == GameState.END_WIN:
			add_score()
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func add_score() -> void:
	if Settings.size_id == Settings.CUSTOM: return
	var time_in_sec := SecTimer._last_second
	var date_time := "%s %s" % [Time.get_date_string_from_system(), Time.get_time_string_from_system()]
	var scores_size_id = scores_table[Settings.size_id] as Array
	for i in 3:
		if scores_size_id[i][0] > time_in_sec:
			scores_size_id.insert(i, [time_in_sec, date_time])
			scores_size_id.remove_at(3)
			_save_scores()
			new_score.emit(Settings.size_id, i)
			return
			
func _load_scores() -> void:
	if !FileAccess.file_exists(_SCORES_PATH):
		_is_scores_loaded = true
		_save_scores()
	else:
		var err := _scores.load(_SCORES_PATH)
		if err != OK: return
		for i in 3:
			for j in 3:
				scores_table[i][j][0] = _scores.get_value("scores", "second_%d_%d" % [i, j])
				scores_table[i][j][1] = _scores.get_value("scores", "data_%d_%d" % [i, j])
		_is_scores_loaded = true

func _save_scores() -> void:
	if not _is_scores_loaded: return
	for i in 3:
		for j in 3:
			_scores.set_value("scores", "second_%d_%d" % [i, j], scores_table[i][j][0])
			_scores.set_value("scores", "data_%d_%d" % [i, j], scores_table[i][j][1])
	_scores.save(_SCORES_PATH)
