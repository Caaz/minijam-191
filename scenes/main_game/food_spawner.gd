class_name FoodSpawner extends Area3D
@export var FoodScene:PackedScene

@export var spawn_area:CollisionShape3D
@export var spawn_timer:Timer
@export var game:MainGame
@export var food_type_group:ResourceGroup
var food_types:Array[FoodType]
var current_gravity_scale: float = 1.0

func _ready() -> void:
	food_type_group.load_all_into(food_types)
	spawn_timer.timeout.connect(_spawn_food)
	# Add to group so stage manager can find us
	add_to_group("food_spawner")

func _spawn_food() -> void:
	var food:Food = FoodScene.instantiate() as Food
	food.type = food_types.pick_random()
	food.position = _get_spawnpoint()
	
	# Apply current gravity scale to the food
	food.gravity_scale = current_gravity_scale
	
	food.hit_floor.connect(func():
		game.strikes += 1
		$"../BadSound".play()
	)
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

# Updated method for stage manager to update both spawn interval and gravity
func update_spawn_settings(new_interval: float, gravity_scale: float) -> void:
	spawn_timer.wait_time = new_interval
	current_gravity_scale = gravity_scale
