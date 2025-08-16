class_name GameplayUI extends Control

@export var game:MainGame
@export var score_label:Label
@export var time_label:Label
@export var stage_label:Label
@export var buy_crate_button:Button
@export var upgrade_crate_speed_button: Button
@export var strike_container:Control
@export var strike_texture:Texture2D

func _ready() -> void:
	game.score_changed.connect(func(new_score:int):
		score_label.text = "Points: %05d" % new_score
	)
	
	for i:int in range(0, game.MAX_STRIKES):
		add_strike_display()
		
	game.strikes_changed.connect(func(strike_count:int):
		if strike_count >= strike_container.get_child_count():
			return
		var strike:Node = strike_container.get_child(strike_count)
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

func _on_stage_manager_stage_changed(_new_stage: int, description: String) -> void:
	stage_label.visible = true
	stage_label.text = description

func _input(event: InputEvent) -> void:
	if game.current_upgrade_mode == GlobalData.CrateUpgrade.NONE:
		return
	if event is InputEventMouseButton:
		if event.pressed:
			game.click_raycast_crates.position = game.camera.project_ray_origin(event.position)
			game.click_raycast_crates.target_position = game.camera.project_ray_normal(event.position) * 100
			game.click_raycast_crates.force_raycast_update()
			if not game.click_raycast_crates.is_colliding():
				game.process_mode = Node.PROCESS_MODE_INHERIT
				return
				
			var collider = game.click_raycast_crates.get_collider()
			if collider is Area3D:
				var crate: Crate = collider.get_parent()
				var upgrade_cost = crate.get_upgrade_cost(game.current_upgrade_mode)
				if upgrade_cost <= game.score:
					crate.upgrade(game.current_upgrade_mode)
					game.score -= upgrade_cost
					game.process_mode = Node.PROCESS_MODE_INHERIT
	pass
	
