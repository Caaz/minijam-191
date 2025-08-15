class_name Prototype extends Node3D

signal score_changed(score:int)
signal striked(current_strikes:int)
signal striked_out()

@export var crate_types: Dictionary[String, Mesh]
@export var foods: Dictionary[String, Mesh]
@export var crate_positions: Array[Vector3]
@export var CrateScene:PackedScene
var start_num_crates: int = 1

var score:int = 0:
	set(new_score):
		score = new_score
		score_changed.emit(score)

var strikes: int = 0
var max_strikes: int = 5

var current_crate: CharacterBody3D

func _ready() -> void:
	start_num_crates = clamp(start_num_crates, 0, crate_types.size())
	add_crate()
	striked.connect(func(num): print("Strike " + str(num)))
	striked_out.connect(func(): print("Strike, you're out!"))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			shoot_ray()
			
func strike():
	if strikes < max_strikes:
		strikes+=1
		if strikes < max_strikes:
			striked.emit(strikes)
		elif strikes == max_strikes:
			striked.emit(strikes)
			striked_out.emit()

func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = $Camera3D.project_ray_origin(mouse_pos)
	var to = from + $Camera3D.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world_3d().direct_space_state

	var params = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = 0b00000000_00000000_00000001_00000000

	var result = space_state.intersect_ray(params)

	if result and result.collider:
		if result.collider is CharacterBody3D:
			current_crate = result.collider
		elif result.collider is GridMap:
			if current_crate:
				current_crate.target_location = result.position


func _on_spawner_timer_timeout() -> void:
	var falling_food := preload("res://darknightskystuff/falling_food.tscn").instantiate()
	falling_food.hit_the_ground.connect(func():
		strike()
		)

	var cshape: CollisionShape3D = $Area3D/CollisionShape3D
	var box: BoxShape3D = cshape.shape
	var half: Vector3 = box.size * 0.5

	# Random point inside the box (projected on XZ)
	var local: Vector3 = Vector3(
							 randf_range(-half.x, half.x),
							 0.0,
							 randf_range(-half.z, half.z)
						 )

	var spawn: Vector3 = cshape.to_global(local)  # or: (cshape.global_transform * local)
	spawn.y = 2.537

	add_child(falling_food)
	falling_food.global_position = spawn

	var food = foods.values().pick_random()
	falling_food.get_child(0).get_child(0).mesh = food
	falling_food.get_child(1).mesh = food

func add_crate() -> void:
	var crate = CrateScene.instantiate()
	crate.position = crate_positions.pick_random()
	crate.get_child(0).mesh = crate_types.values().pick_random()
	crate.food_captured.connect(func(points:int):
		score += points
	)
	add_child(crate)
