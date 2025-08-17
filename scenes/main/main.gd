class_name Game extends Node

@export var main_menu:MainMenu
@export var main_game:MainGame
@export var lose_screen:LoseScreen

func _ready() -> void:
	main_menu.play_button.pressed.connect(func():
		main_game.start()
		main_menu.hide()
		$MainMenuMusic.stop()
		$SelectSound.play()
	)
	
	main_game.game_over.connect(func():
		main_game.stop()
		lose_screen.show()
		$EndGameMusic.play()
	)
	
	lose_screen.reset_button.pressed.connect(func():
		lose_screen.hide()
		$EndGameMusic.stop()
		main_menu.show()
		main_game.initialize()
	)
