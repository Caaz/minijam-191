class_name Game extends Node

@export var main_menu:MainMenu
@export var main_game:MainGame

func _ready() -> void:
	main_menu.play_button.pressed.connect(func():
		main_game.start()
		main_menu.hide()
	)
	
	main_game.game_over.connect(func():
		get_tree().change_scene_to_file("res://scenes/lose_screen/lose_screen.tscn")
		)
