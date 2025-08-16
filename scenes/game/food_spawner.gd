extends Area3D
@export var FoodScene:PackedScene

@export var spawn_area:CollisionShape3D
@export var spawn_timer:Timer

@export var food_type_group:ResourceGroup
var food_types:Array[FoodType]

func _ready() -> void:
	food_type_group.load_all_into(food_types)
	spawn_timer.timeout.connect(_spawn_food)

func _spawn_food() -> void:
	var food:Food = FoodScene.instantiate() as Food
	food.type = food_types.pick_random()
	food.position = _get_spawnpoint()
	add_child(food)
	
func _get_spawnpoint() -> Vector3:
	var box:BoxShape3D = spawn_area.shape as BoxShape3D
	var point:Vector3 = Vector3(
		randf() * box.size.x,
		randf() * box.size.y,
		randf() * box.size.z,
	)
	# Center it
	point -= box.size / 2
	# Offset it by the shape's position
	point += spawn_area.global_position
	return point
