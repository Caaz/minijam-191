class_name FoodSpawner extends Area3D
@export var FoodScene:PackedScene

@export var spawn_area:CollisionShape3D
@export var spawn_timer:Timer
@export var game:MainGame
@export var food_type_group:ResourceGroup
var food_types:Array[FoodType]
@export var stage_manager:StageManager

func _ready() -> void:
	food_type_group.load_all_into(food_types)
	spawn_timer.timeout.connect(func():
		var multiple_spawn_chance: float = randf_range(0, 100)
		var food_spawned: Food = _spawn_food()
		if multiple_spawn_chance < stage_manager.stage.chance_of_multiple_spawn:
			var position_increment: float = 0
			var amount_to_spawn: int = randi_range(1, stage_manager.stage.max_multiple_spawn_num)
			for times in amount_to_spawn:
				position_increment+= 1
				var food_position = food_spawned.position
				food_position.x += position_increment
				_spawn_food(true, true, food_spawned.type, food_position)
				pass
		)
	stage_manager.stage_changed.connect(func(level:int, stage:Stage):
		spawn_timer.wait_time = stage.spawn_time / max(1,float(level)/float(stage_manager.stages.size()))
	)

func _spawn_food(gave_type: bool = false, gave_position: bool = false, given_type: FoodType = null, given_position: Vector3 = Vector3.INF) -> Food:
	var food:Food = FoodScene.instantiate() as Food
	if not gave_type:
		food.type = food_types.pick_random()
	else:
		food.type = given_type
	if not gave_position:
		food.position = _get_spawnpoint()
	else:
		food.position = given_position
	# Apply current gravity scale to the food
	food.gravity_scale = stage_manager.stage.gravity_scale
	
	food.hit_floor.connect(func():
		if food.type.points > 0:
			game.strikes += 1
	)
	add_child(food)
	return food
	
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
