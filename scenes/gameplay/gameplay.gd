class_name Gameplay extends Node
@export var ui:GameplayUI
@export var game:Prototype

func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	ui.hide()
	
func start():
	process_mode = Node.PROCESS_MODE_INHERIT
	ui.show()
