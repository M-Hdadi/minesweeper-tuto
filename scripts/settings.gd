extends Node

signal size_changed(new_size_id: int)

const FILE_PATH := "user://config.cfg"
const CONFIG := "config"

const CUSTOM_WIDTH_KEY := "custom_width"
const CUSTOM_HEIGHT_KEY := "custom_height"
const CUSTOM_MINES_KEY := "custom_mines"
const SIZE_ID_KEY := "size_id"

const BEGINNER := 0
const INTERMEDIATE := 1
const ADVANCED := 2
const CUSTOM := 3

const _sizes := [[9, 9, 10], [16, 16, 40], [30, 16, 99]]
const _window_sizes : = [[238, 358], [392, 512], [700, 512]]

var _config_loaded := false
var _config := ConfigFile.new()

var custom_width := 9:
	get:
		return custom_width
	set(value):
		if value != custom_width:
			custom_width = value
			_save_config()

var custom_height := 9:
	get:
		return custom_height
	set(value):
		if value != custom_height:
			custom_height = value
			_save_config()

var custom_mines := 10:
	get:
		return custom_mines
	set(value):
		if value != custom_mines:
			custom_mines = value
			_save_config()

var size_id := BEGINNER:
	get:
		return size_id
	set(new_size_id):
		if new_size_id < BEGINNER || new_size_id > CUSTOM || new_size_id == size_id:
			return
		size_id = new_size_id
		_save_config()

var width : int:
	get:
		if size_id == CUSTOM : return custom_width
		return _sizes[size_id][0]

var height : int :
	get:
		if size_id == CUSTOM : return custom_height
		return _sizes[size_id][1]

var mine_count: int :
	get:
		if size_id == CUSTOM : return custom_mines
		return _sizes[size_id][2]

var window_size : Vector2i:
	get:
		return Vector2i(width, height) * 22
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_config()
	_resizing_window()

func _load_config() -> void:
	if !FileAccess.file_exists(FILE_PATH):
		_config_loaded = true
		_save_config()
	else:
		var err = _config.load(FILE_PATH)
		if err == OK:
			if _config.has_section_key(CONFIG, CUSTOM_WIDTH_KEY):
				custom_width = _config.get_value(CONFIG, CUSTOM_WIDTH_KEY)
				
			if _config.has_section_key(CONFIG, CUSTOM_HEIGHT_KEY):
				custom_height = _config.get_value(CONFIG, CUSTOM_HEIGHT_KEY)
				
			if _config.has_section_key(CONFIG, CUSTOM_MINES_KEY):
				custom_mines = _config.get_value(CONFIG, CUSTOM_MINES_KEY)
				
			if _config.has_section_key(CONFIG, SIZE_ID_KEY):
				size_id = _config.get_value(CONFIG, SIZE_ID_KEY)
			_config_loaded = true
		else:
			print("Error: in loadinf file \"%s\"" % FILE_PATH)

func _save_config() -> void:
	if !_config_loaded: return
	_config.set_value(CONFIG, CUSTOM_WIDTH_KEY, custom_width)
	_config.set_value(CONFIG, CUSTOM_HEIGHT_KEY, custom_height)
	_config.set_value(CONFIG, CUSTOM_MINES_KEY, custom_mines)
	_config.set_value(CONFIG, SIZE_ID_KEY, size_id)
	_config.save(FILE_PATH)

func _resizing_window() -> void:
	var x : int
	var y : int
	if size_id < CUSTOM:
		x = _window_sizes[size_id][0]
		y = _window_sizes[size_id][1]
	else:
		x = custom_width * 22 + 40
		y = custom_height * 22 + 40 + 120
	get_window().size = Vector2i(x, y)

func invoke_events() -> void:
	_resizing_window()
	size_changed.emit(size_id)
