class_name GameplayUI extends Control

@export var game:MainGame
@export var score_label:Label
@export var time_label:Label
@export var stage_label:Label
@export var buy_crate_button:Button
@export var strike_container:Control
@export var strike_texture:Texture2D

func _ready() -> void:
	game.score_changed.connect(func(new_score:int):
		score_label.text = "Score: %05d" % new_score
	)
	
	for i:int in range(0, game.MAX_STRIKES):
		add_strike_display()
		
	game.strikes_changed.connect(func(strike_count:int):
		var strike:Node = strike_container.get_child(strike_count - 1)
		if not strike:
			return
		strike.visible = true
	)
	game.seconds_changed.connect(func(seconds:float):
		time_label.text = "Time: %02d:%02d" % [floor(seconds/60), (fmod(seconds, 60))]
	)

func add_strike_display():
	var strike = TextureRect.new()
	strike.visible = false
	strike.texture = strike_texture
	strike.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	strike_container.add_child(strike)
	


func _on_stage_manager_stage_changed(new_stage: int, description: String) -> void:
	stage_label.visible = true
	stage_label.text = description
	pass # Replace with function body.
