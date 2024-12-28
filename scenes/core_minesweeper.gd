extends Control
@onready var block_parent: Control = $BlockParent
@onready var click_control: Control = $ClickControl

const _MAX_LENGTH := 720
const _I_J_VALUES := [-1, 0, 1]
const BLOCK : PackedScene = preload("res://scenes/block.tscn")
var _blocks : Array[Block] = []

var current_mine_count : int

var _block_size : float
var _closed_block_left : int

var length : int:
	get:
		return Settings.width * Settings.height

func _ready() -> void:
	_blocks.resize(_MAX_LENGTH)
	block_parent.position = Vector2(20.0, 20.0)
	click_control.position = Vector2(20.0, 20.0)
	for i in _MAX_LENGTH:
		var block := BLOCK.instantiate() as Block
		_blocks[i] = block
		block_parent.add_child(block)
	_reset_blocks()
	
	Settings.size_changed.connect(func(_size_id: int):
		_reset_blocks()
		)
	GameState.game_state_changed.connect(func(game_state: int):
		if game_state == GameState.START_STATE:
			_reset_blocks()
		)
	click_control.gui_input.connect(_on_click)

func _reset_blocks() -> void:
	for i in _MAX_LENGTH:
		_blocks[i].visible = false
	
	for i in length:
		_blocks[i].visible = true
		_blocks[i].visibility = Block.CLOSED
	
	_block_size = _blocks[0].size.x
	for i in length:
		var x := i % Settings.width
		@warning_ignore("integer_division")
		var y := i / Settings.width
		_blocks[i].position = Vector2(x, y) * _block_size
	
	click_control.size = Vector2(Settings.width, Settings.height) * _block_size
	size =  Settings.window_size

func _play(index : int) -> void:
	if GameState.game_state == GameState.START_STATE:
		_start_game(index)
		return
	if GameState.game_state == GameState.PLAY_STATE:
		_open(index)
		return
	if GameState.game_state == GameState.END_STATE:
		_reset_blocks()
		GameState.start()

func _set_mines() -> void:
	for i in length:
		_blocks[i].value = Block.EMPTY_BLOCK
	for i in Settings.mine_count:
		_blocks[i].value = Block.MINE_BLOCK

func _safe_blocks(index: int) -> int:
	var i := index % Settings.width
	@warning_ignore("integer_division")
	var j := index / Settings.width
	var count := 0
	
	for new_i in _I_J_VALUES:
		if i + new_i < 0 || i + new_i >= Settings.width: continue
		for new_j in _I_J_VALUES:
			if j + new_j < 0 || j + new_j >= Settings.height: continue
			count += 1
	return count

func _distrepute_mines(safe_block_count: int) -> void:
	var max_length = length - safe_block_count - 1
	for i in max_length:
		var rand_index := randi_range(i + 1, max_length - 1)
		var tmp_value := _blocks[i].value
		_blocks[i].value = _blocks[rand_index].value
		_blocks[rand_index].value = tmp_value

func _move_safe_blocks(index: int) -> void:
	var i := index % Settings.width
	@warning_ignore("integer_division")
	var j := index / Settings.width
	var block_moved := 1
	for new_i in _I_J_VALUES:
		var x : int = i + new_i
		if x < 0 || x >= Settings.width: continue
		for new_j in _I_J_VALUES:
			var y : int = j + new_j
			if y < 0 || y >= Settings.height: continue
			var new_index := y * Settings.width + x
			_blocks[length - block_moved].value = _blocks[new_index].value
			_blocks[new_index].value = Block.EMPTY_BLOCK
			block_moved  += 1

func _block_mines() -> void:
	for index in length:
		if _blocks[index].value == Block.MINE_BLOCK: continue
		var i := index % Settings.width
		@warning_ignore("integer_division")
		var j := index / Settings.width
		for new_i in _I_J_VALUES:
			var x : int = i + new_i
			if x < 0 || x >= Settings.width: continue
			for new_j in _I_J_VALUES:
				var y : int = j + new_j
				if y < 0 || y >= Settings.height: continue
				if x == i and y == j: continue
				var new_index := y * Settings.width + x
				if _blocks[new_index].value == Block.MINE_BLOCK:
					_blocks[index].value += 1

func _start_game(index: int) -> void:
	_set_mines()
	var safe_block_count := _safe_blocks(index)
	_distrepute_mines(safe_block_count)
	_move_safe_blocks(index)
	_block_mines()
	GameState.play()
	current_mine_count = Settings.mine_count
	_closed_block_left = length - Settings.mine_count
	_open(index)
	GameState.emit_event(0, current_mine_count)

func _open(index: int, is_first : bool = true) -> void:
	if is_first:
		GameState.emit_event(1, 0)
	if _blocks[index].value == Block.MINE_BLOCK:
		if is_first:
			print("you lose")
			for i in length:
				if _blocks[i].visibility == Block.MARKED && _blocks[i].value != Block.MINE_BLOCK:
					_blocks[i].value = Block.FALSE_MINE
				_blocks[i].visibility = Block.OPENED
			_blocks[index].value = Block.MINE_EXPLODED
			GameState.end_minesweeper = GameState.END_LOSE
			GameState.end()
		return
	else:
		if _blocks[index].visibility == Block.OPENED:
			return
		_blocks[index].visibility = Block.OPENED
		_closed_block_left -= 1
		if _closed_block_left <= 0:
			GameState.end_minesweeper = GameState.END_WIN
			GameState.end()
			return
		if _blocks[index].value == Block.EMPTY_BLOCK:
			var i := index % Settings.width
			@warning_ignore("integer_division")
			var j := index / Settings.width
			for new_i in _I_J_VALUES:
				var x : int = i + new_i
				if x < 0 || x >= Settings.width: continue
				for new_j in _I_J_VALUES:
					var y : int = j + new_j
					if y < 0 || y >= Settings.height: continue
					if x == i and y == j: continue
					var new_index := y * Settings.width + x
					_open(new_index, false)

func _mark(index: int) -> void:
	if _blocks[index].visibility != Block.OPENED:
		if _blocks[index].visibility == Block.MARKED:
			current_mine_count += 1
			GameState.emit_event(0, current_mine_count)
		_blocks[index].visibility += 1
		_blocks[index].visibility %= 3
		if _blocks[index].visibility == Block.MARKED:
			current_mine_count -= 1
			GameState.emit_event(0, current_mine_count)

func _chord(index : int) -> void:
	if _blocks[index].visibility != Block.OPENED: return
	var i := index % Settings.width
	@warning_ignore("integer_division")
	var j := index / Settings.width
	@warning_ignore("shadowed_variable")
	var mine_count := 0
	for new_i in _I_J_VALUES:
		var x : int = i + new_i
		if x < 0 || x >= Settings.width: continue
		for new_j in _I_J_VALUES:
			var y : int = j + new_j
			if y < 0 || y >= Settings.height: continue
			if x == i and y == j: continue
			var new_index := y * Settings.width + x
			if _blocks[new_index].visibility == Block.MARKED:
				if _blocks[new_index].value == Block.MINE_BLOCK:
					mine_count += 1
				else:
					return
	if mine_count == _blocks[index].value && mine_count > 0:
		GameState.emit_event(1, 0)
		for new_i in _I_J_VALUES:
			var x : int = i + new_i
			if x < 0 || x >= Settings.width: continue
			for new_j in _I_J_VALUES:
				var y : int = j + new_j
				if y < 0 || y >= Settings.height: continue
				if x == i and y == j: continue
				var new_index := y * Settings.width + x
				_open(new_index, false)

func _on_click(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		var x := (int)((event as InputEventMouseButton).position.x / _block_size)
		var y := (int)((event as InputEventMouseButton).position.y / _block_size)
		var index := y * Settings.width + x
		if event.button_index == MOUSE_BUTTON_LEFT:
			_play(index)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if GameState.game_state == GameState.PLAY_STATE:
				_mark(index)
			elif GameState.game_state == GameState.START_STATE:
				_play(index)
		elif  event.button_index == MOUSE_BUTTON_MIDDLE:
			if GameState.game_state == GameState.PLAY_STATE:
				_chord(index)
			elif GameState.game_state == GameState.START_STATE:
				_play(index)
		
