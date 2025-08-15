class_name GameplayUI extends Control

@export var prototype:Prototype
@export var score_label:Label
@export var time_label:Label
@export var buy_crate_button:Button

func _ready() -> void:
	print(prototype)
	prototype.score_changed.connect(func(new_score:int):
		print("Score changed and caught")
		score_label.text = "Score: %05d" % new_score
	)
