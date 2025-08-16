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
@export var ui:GameplayUI
@export var ground_spawner: GroundSpawner

@export var custom_grid_map: CustomGridMap

## Current selected crate
var selected_crate:Crate
var crate_cost: int = 2:
	set(new_cost):
		crate_cost = new_cost
		ui.buy_crate_button.text = "Buy Crate (" + str(crate_cost) + " Points)"

var score:int = 0:
	set(new_score):
		score = new_score
		score_changed.emit(score)

var strikes: int = 0:
	set(new_strikes):
		strikes = new_strikes
		strikes_changed.emit(strikes)
		if strikes >= MAX_STRIKES:
			game_over.emit()

var _seconds:int = 0
var elapsed_seconds: float = 0:
	set(new_seconds):
		elapsed_seconds = new_seconds
		if _seconds != floor(elapsed_seconds):
			seconds_changed.emit(elapsed_seconds)

func _ready() -> void:
	custom_grid_map.create_square(Vector3i(0,0,0), 8)
	process_mode = Node.PROCESS_MODE_DISABLED
	ui.hide()
	ui.buy_crate_button.text = "Buy Crate (" + str(crate_cost) + " Points)"
	ui.buy_crate_button.pressed.connect(func():
		if score >= crate_cost:
			score -= crate_cost
			add_crate()
		)

func _process(delta:float) -> void:
	elapsed_seconds += delta
	
func start() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	add_crate()
	ui.show()
	$BackgroundMusic.play()
	
func add_crate() -> void:
	$SelectSound.play()
	var crate:Crate = ground_spawner.spawn_crate()
	crate.selected.connect(_on_crate_selected.bind(crate))
	crate.caught.connect(_on_food_caught)

func _on_food_caught(food:Food):
	score += food.type.points
	$GoodSound.play()

func _on_crate_selected(crate:Crate):
	print("crate selected ", crate)
	selected_crate = crate
	selected_crate.new_path()

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
