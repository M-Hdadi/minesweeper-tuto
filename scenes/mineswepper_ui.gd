extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer

@onready var settings_parent: Control = $SettingParent
@onready var scores_parent: Control = $ScoresParent
@onready var winning_parent: Control = $WinningParent

const start_pos := Vector2(0.0, 1000.0)
const end_pos := Vector2(0.0, 100.0)

var _wnd_opened : Control = null

func _ready() -> void:
	settings_parent.visible = false
	settings_parent.position =start_pos
	scores_parent.visible = false
	scores_parent.position = start_pos
	winning_parent.visible = false
	winning_parent.position = start_pos
	v_box_container.position = Vector2.ZERO
	GameState.new_event.connect(func(event_id: int, _event_data):
		match event_id:
			GameState.OPEN_SETTINGS_ID:
				_open_settings()
			GameState.OPEN_SCORES_ID:
				_open_scores()
			GameState.OPEN_WINNING_ID:
				_open_winning()
			GameState.CLOSE_WND_ID:
				_close_wnd()
		)
	Settings.size_changed.connect(func(_size_id):
		v_box_container.size = Settings.window_size
		v_box_container.position = Vector2.ZERO
		)

func _open_settings() -> void:
	_open_wnd(settings_parent)

func _open_scores() -> void:
	_open_wnd(scores_parent)

func _open_winning() -> void:
	_open_wnd(winning_parent)

func _open_wnd(parent_wnd: Control) -> void:
	if !_wnd_opened:
		parent_wnd.visible = true
		_wnd_opened = parent_wnd
		var tween := get_tree().create_tween()
		tween.tween_property(parent_wnd, "position", end_pos, 0.3)

func _close_wnd() -> void:
	if _wnd_opened:
		var tween := get_tree().create_tween()
		tween.tween_property(_wnd_opened, "position", start_pos, 0.3)
		tween.tween_callback(func():
			_wnd_opened.visible = false
			_wnd_opened = null
			)
