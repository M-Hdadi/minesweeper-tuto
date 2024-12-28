extends Control
@onready var score_1: Score = $MarginContainer/VBoxContainer2/VBoxContainer/Score1
@onready var score_2: Score = $MarginContainer/VBoxContainer2/VBoxContainer/Score2
@onready var score_3: Score = $MarginContainer/VBoxContainer2/VBoxContainer/Score3

@onready var beginner: Button = $MarginContainer/VBoxContainer2/HBoxContainer/Beginner
@onready var intermediate: Button = $MarginContainer/VBoxContainer2/HBoxContainer/Intermediate
@onready var advanced: Button = $MarginContainer/VBoxContainer2/HBoxContainer/Advanced

@onready var close: Button = $MarginContainer/VBoxContainer2/HBoxContainer2/Close

var current_size_id: int = 0


func _ready() -> void:
	_display_scores(0)
	beginner.pressed.connect(_display_scores.bind(0))
	intermediate.pressed.connect(_display_scores.bind(1))
	advanced.pressed.connect(_display_scores.bind(2))
	Scores.new_score.connect(func(id, _index):
		if id == current_size_id:
			_display_scores(id)
		)
	close.pressed.connect(func():
		GameState.emit_event(GameState.CLOSE_WND_ID, null)
		)

func _display_scores(index: int) -> void:
	if index < 0 || index > 2: return
	current_size_id = index
	score_1.set_score(Scores.scores_table[index][0][1], str(Scores.scores_table[index][0][0]))
	score_1.visible = Scores.scores_table[index][0][0] < 10000
	score_2.set_score(Scores.scores_table[index][1][1], str(Scores.scores_table[index][1][0]))
	score_2.visible = Scores.scores_table[index][1][0] < 10000
	score_3.set_score(Scores.scores_table[index][2][1], str(Scores.scores_table[index][2][0]))
	score_3.visible = Scores.scores_table[index][2][0] < 10000
