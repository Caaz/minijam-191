class_name Food extends RigidBody3D
signal hit_floor()

@export var type:FoodType
@export var mesh_instance:MeshInstance3D
@export var collision_shape:CollisionShape3D

func _ready() -> void:
	mesh_instance.mesh = type.mesh
	collision_shape.shape = type.collision_shape
	_place_sprite()

func _place_sprite() -> void:
	var sprite:Sprite3D = Sprite3D.new()
	sprite.texture = type.icon
	sprite.top_level = true
	sprite.position = Vector3(global_position.x, 0.001, global_position.z)
	sprite.rotation = Vector3(PI/2,0,0)
	sprite.shaded = true
	sprite.pixel_size = .005
	add_child(sprite)

func _physics_process(_delta) -> void:
	var bodies:Array[Node3D] = get_colliding_bodies()
	if bodies.size() > 0:
		if bodies[0].is_in_group(&"floor"):
			hit_floor.emit()
			queue_free()
