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

func _process(delta: float) -> void:
	var elapsed_seconds: int = snapped(game.elapsed_milliseconds, 0)
	ui.time_label.text = "Time: %02d:%02d" % [floor(elapsed_seconds/60), (fmod(elapsed_seconds, 60))]
	pass
