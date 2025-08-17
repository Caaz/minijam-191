class_name GameplayUI extends Control

@export var game:MainGame
@export var score_label:Label
@export var time_label:Label
@export var stage_label:Label
@export var buy_crate_button:Button
@export var upgrade_crate_speed_button: Button
@export var upgrade_crate_size_button: Button
@export var strike_container:Control
@export var strike_texture:Texture2D
@export var stage_manager:StageManager

func _ready() -> void:
	game.score_changed.connect(func(new_score:int):
		score_label.text = "Points: %05d" % new_score
	)
	
	for i:int in range(0, game.MAX_STRIKES):
		add_strike_display()
		
	game.strikes_changed.connect(func(strike_count:int):
		for strike_display in strike_container.get_children():
			strike_display.visible =  strike_display.get_index() < strike_count
	)
	game.seconds_changed.connect(func(seconds:float):
		time_label.text = "Time: %02d:%02d" % [floor(seconds/60), (fmod(seconds, 60))]
	)
	stage_manager.stage_changed.connect(func(level:int, stage:Stage):
		stage_label.visible = true
		stage_label.text = "Level %d\n%s" % [level, stage.stage_name]
	)

func add_strike_display():
	var strike = TextureRect.new()
	strike.visible = false
	strike.texture = strike_texture
	strike.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	strike_container.add_child(strike)

func disable_all_upgrade_buttons() -> void:
	upgrade_crate_size_button.button_pressed = false
	upgrade_crate_speed_button.button_pressed = false
