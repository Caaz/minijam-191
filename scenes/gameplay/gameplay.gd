class_name Gameplay extends Node
@export var ui:GameplayUI
@export var game:Prototype

func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	ui.hide()
	ui.buy_crate_button.pressed.connect(func ():
		game.add_crate()
	)
	
func start():
	process_mode = Node.PROCESS_MODE_INHERIT
	ui.show()
