extends Node3D

@export var crate_types: Dictionary[String, Mesh]
@export var foods: Dictionary[String, Mesh]
@export var crate_positions: Array[Vector3]
var start_num_crates: int = 1


var current_crate: CharacterBody3D

func _ready() -> void:
	start_num_crates = clamp(start_num_crates, 0, crate_types.size())
	var crate = preload("res://darknightskystuff/custom_crate.tscn").instantiate()
	crate.position = crate_positions.pick_random()
	crate.get_child(0).mesh = crate_types.values().pick_random()
	add_child(crate)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			shoot_ray()

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


	pass # Replace with function body.
