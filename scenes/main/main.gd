class_name Game extends Node

@export var main_menu:MainMenu
@export var gameplay:Gameplay

func _ready() -> void:
	main_menu.play_button.pressed.connect(func():
		gameplay.start()
		gameplay.process_mode = Node.PROCESS_MODE_INHERIT
		main_menu.hide()
	)
