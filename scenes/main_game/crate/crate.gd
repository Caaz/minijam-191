class_name Crate extends CharacterBody3D

signal selected()
signal caught(food:Food)
@export var PathScene:PackedScene
@export var selection_ui:Sprite3D
@export var catching_area:Area3D
@export var cost_label:Label3D

var path:Path
var speed:float = 10

var upgrade_levels: Dictionary = {GlobalData.UpgradeMode.CRATE_SPEED: 0, GlobalData.UpgradeMode.CRATE_SIZE: 0}
var upgrade_properties: Dictionary = {GlobalData.UpgradeMode.CRATE_SPEED: "speed", GlobalData.UpgradeMode.CRATE_SIZE: "scale"}
var upgrade_values: Dictionary = {GlobalData.UpgradeMode.CRATE_SPEED: [10, 20, 30, 40, 50], GlobalData.UpgradeMode.CRATE_SIZE: [Vector3(1,1,1), Vector3(1.2,1.2,1.2), Vector3(1.6,1.6,1.6), Vector3(2.0,2.0,2.0), Vector3(2.4,2.4,2.4)]}
var upgrade_costs: Dictionary = {GlobalData.UpgradeMode.CRATE_SPEED: [0, 1, 2, 3, 4], GlobalData.UpgradeMode.CRATE_SIZE: [0, 1, 2, 3, 4]}

var is_selected:bool = false:
	set(new_selected):
		is_selected = new_selected
		if is_selected:
			selection_ui.show()
			selected.emit()
		else:
			selection_ui.hide()

func _ready() -> void:
	mouse_entered.connect(cost_label.show)
	mouse_exited.connect(cost_label.hide)
	catching_area.body_entered.connect(func(body:Node3D):
		var food:Food = body as Food
		if not food or food.type.points <= 0:
			return
		
		caught.emit(food)
		food.queue_free()
	)

func get_upgrade_cost(upgrade_mode: GlobalData.UpgradeMode) -> int:
	if upgrade_levels[upgrade_mode] + 1 < upgrade_costs[upgrade_mode].size():
		return upgrade_costs[upgrade_mode][upgrade_levels[upgrade_mode] + 1]
	return -1

func upgrade(upgrade_mode: GlobalData.UpgradeMode):
	if upgrade_levels[upgrade_mode] + 1 < upgrade_costs[upgrade_mode].size():
		upgrade_levels[upgrade_mode] = upgrade_levels[upgrade_mode] + 1
		set(upgrade_properties[upgrade_mode], upgrade_values[upgrade_mode][upgrade_levels[upgrade_mode]])
	
func _input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed(&"select"):
		is_selected = true

## Creates a new path, removing the old one if it exists.
func new_path() -> void:
	if path:
		path.queue_free()
	
	path = PathScene.instantiate() as Path
	add_child(path)
	path.add_point(global_position)

func _physics_process(delta:float) -> void:
	if not path or path.points.size() <= 1:
		return
	
	var target:Vector3 = position
	target = path.follower.global_position
	if position.distance_to(target) > 0.5:
		velocity = position.direction_to(target) * speed
	else:
		velocity = Vector3.ZERO
		path.follower.progress += delta * speed * 2
		path.update_line_display()
	move_and_slide()

	if not is_selected and is_equal_approx(path.follower.progress_ratio, 1.0):
		path.queue_free()
		

func destroy() -> void:
#	Maybe do another particle explosion here I donno
	queue_free()
