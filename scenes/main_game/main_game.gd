class_name MainGame extends Node3D
signal score_changed(score:int)
signal strikes_changed(strike:int)
signal seconds_changed(seconds:int)
signal game_over()

const MAX_STRIKES:int = 3

@export var CrateScene:PackedScene
@export var camera:Camera3D
## This node handles raycasts for clicks, because I don't want to bother with managing all the raycast code for doing this manually.
@export var click_raycast:RayCast3D
@export var click_raycast_crates:RayCast3D
@export var ui:GameplayUI
@export var ground_spawner: GroundSpawner

@export var custom_grid_map: CustomGridMap
@export var stage_manager:StageManager

var current_upgrade_mode: GlobalData.UpgradeMode = GlobalData.UpgradeMode.NONE

## Current selected crate
var selected_crate:Crate
var crate_cost: int = 2:
	set(new_cost):
		crate_cost = new_cost

var score:int = 0:
	set(new_score):
		score = new_score
		score_changed.emit(score)

var strikes: int = 0:
	set(new_strikes):
		if new_strikes > strikes:
			$BadSound.play()
		strikes = new_strikes
		strikes_changed.emit(strikes)
		if strikes >= MAX_STRIKES:
			game_over.emit()

var _seconds:int = 0
var elapsed_seconds: float = 0:
	set(new_seconds):
		elapsed_seconds = new_seconds
		if _seconds != floor(elapsed_seconds):
			_seconds = floor(elapsed_seconds)
			seconds_changed.emit(elapsed_seconds)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	ui.hide()
	ui.buy_crate_button.pressed.connect(func():
		if score >= crate_cost:
			score -= crate_cost
			add_crate()
		)
	ui.upgrade_crate_speed_button.toggled.connect(func(toggled_on: bool):
		if toggled_on:
			current_upgrade_mode = GlobalData.UpgradeMode.CRATE_SPEED
		else:
			current_upgrade_mode = GlobalData.UpgradeMode.NONE
	)
	ui.upgrade_crate_size_button.toggled.connect(func(toggled_on: bool):
		if toggled_on:
			current_upgrade_mode = GlobalData.UpgradeMode.CRATE_SIZE
		else:
			current_upgrade_mode = GlobalData.UpgradeMode.NONE
	)

func _process(delta:float) -> void:
	elapsed_seconds += delta

func initialize() -> void:
	custom_grid_map.create_square(Vector3i(0,0,0), 8)
	ui.hide()
	score = 0
	elapsed_seconds = 0
	strikes = 0
	for crate in get_tree().get_nodes_in_group(&"crate"):
		crate.queue_free()
	for food in get_tree().get_nodes_in_group(&"food"):
		food.queue_free()
		
	stage_manager.reset()

func start() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	initialize()
	add_crate()
	ui.show()
	$BackgroundMusic.play()

func stop():
	$BackgroundMusic.stop()
	process_mode = Node.PROCESS_MODE_DISABLED

func add_crate() -> void:
	$SelectSound.play()
	var crate:Crate = ground_spawner.spawn_crate()
	crate.selected.connect(_on_crate_selected.bind(crate))
	crate.caught.connect(_on_food_caught)

func _on_food_caught(food:Food):
	if food.type.points > 0:
		score += food.type.points
		$GoodSound.play()
	else:
		strikes+=1

func _on_crate_selected(crate:Crate):
	selected_crate = crate
	selected_crate.new_path()
	
	if current_upgrade_mode == GlobalData.UpgradeMode.NONE:
		return
	
	crate.cost_label.hide()
	
	var upgrade_cost = crate.get_upgrade_cost(current_upgrade_mode)
	if upgrade_cost <= score and upgrade_cost >= 0:
		crate.upgrade(current_upgrade_mode)
		score -= upgrade_cost
	ui.disable_all_upgrade_buttons()
		

func _input(event:InputEvent):
	if not selected_crate:
		return
		
	if event.is_action_released(&"select"):
		selected_crate.is_selected = false
		selected_crate = null
		return

	if not selected_crate.path:
		return
		
	var mouse_event:InputEventMouseMotion = event as InputEventMouseMotion
	if not mouse_event:
		return
	
	click_raycast.position = camera.project_ray_origin(mouse_event.position)
	click_raycast.target_position = camera.project_ray_normal(mouse_event.position) * 100
	click_raycast.force_raycast_update()
	if not click_raycast.is_colliding():
		return
	selected_crate.path.add_point(click_raycast.get_collision_point())
