extends Control
@onready var close: Button = $Close
@onready var menu_button: MenuButton = $Sizes/MenuButton

@onready var width_lbl: Label = $Sizes/Width_lbl
@onready var width: SpinBox = $Sizes/Width
@onready var height_lbl: Label = $Sizes/Height_lbl
@onready var height: SpinBox = $Sizes/Height
@onready var mines_lbl: Label = $Sizes/Mines_lbl
@onready var mines: SpinBox = $Sizes/Mines

var size_id : int

func _ready() -> void:
	var popup_menu = menu_button.get_popup()
	size_id = Settings.size_id
	enable_custom(size_id == 3)
	menu_button.text = popup_menu.get_item_text(size_id)
	width.value = Settings.custom_width
	height.value = Settings.custom_height
	mines.value = Settings.custom_mines
	popup_menu.id_pressed.connect(func(id: int):
		size_id = id
		menu_button.text = popup_menu.get_item_text(size_id)
		enable_custom(size_id == Settings.CUSTOM)
		)
	close.pressed.connect(func():
		var width_value :=  (int)(width.value + 0.1)
		var height_value := (int)(height.value + 0.1)
		var mines_value := (int)(mines.value + 0.1)
		var is_config_changed := false
		if ((width_value != Settings.custom_width || height_value != Settings.custom_height || mines_value != Settings.custom_mines) && size_id == Settings.CUSTOM) || size_id != Settings.size_id:
			is_config_changed = true
		Settings.custom_width = width_value
		Settings.custom_height = height_value
		Settings.custom_mines = mines_value
		Settings.size_id = size_id
		if is_config_changed:
			Settings.invoke_events()
		GameState.emit_event(GameState.CLOSE_WND_ID, null)
		)

func enable_custom(active: bool) -> void:
	width.editable = active
	height.editable = active
	mines.editable = active
	width_lbl.self_modulate.a = 1. if active else .3
	height_lbl.self_modulate.a = 1. if active else .3
	mines_lbl.self_modulate.a = 1. if active else .3
