class_name GroundSpawner
extends Area3D

@export var CrateScene:PackedScene
@export var spawn_area: CollisionShape3D

func spawn_crate() -> Crate:
	var crate:Crate = CrateScene.instantiate() as Crate
	crate.position = get_random_position()
	add_child(crate)
	return crate

func get_random_position() -> Vector3:
	var box:BoxShape3D = spawn_area.shape as BoxShape3D
	var point:Vector3 = Vector3(
		randf() * box.size.x,
		0,
		randf() * box.size.z,
	)
	# Center it
	point -= box.size / 2
	# Offset it by the shape's position
	point += spawn_area.global_position
	return point
