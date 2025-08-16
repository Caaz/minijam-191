class_name GameplayUI extends Control

@export var game:Game
@export var score_label:Label
@export var time_label:Label
@export var buy_crate_button:Button

func _ready() -> void:
	game.score_changed.connect(func(new_score:int):
		score_label.text = "Score: %05d" % new_score
	)
