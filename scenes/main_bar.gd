extends Control
@onready var timer: ThreeNumbers = $Timer
@onready var mine_counter: ThreeNumbers = $MineCounter
@onready var settings: Button = $Settings
@onready var new_game: Button = $NewGame
@onready var scores: Button = $Scores

func _ready() -> void:
	SecTimer.second.connect(func(sec: int):
		timer.value = sec
		)
	GameState.new_event.connect(func(event_id: int, event_data):
		if event_id == 0:
			mine_counter.value = event_data
		)
	
	new_game.pressed.connect(func():
		GameState.start()
		)
	
	settings.pressed.connect(func():
		GameState.emit_event(GameState.OPEN_SETTINGS_ID, null)
		)
	
	scores.pressed.connect(func():
		GameState.emit_event(GameState.OPEN_SCORES_ID, null)
		)
