class_name Food extends RigidBody3D
@export var food_type:FoodType
@export var mesh_instance:MeshInstance3D
@export var collision_shape:CollisionShape3D

func _ready() -> void:
	mesh_instance.mesh = food_type.mesh
	collision_shape.shape = food_type.collision_shape
	_place_sprite()

func _place_sprite() -> void:
	var sprite:Sprite3D = Sprite3D.new()
	sprite.texture = food_type.icon
	sprite.top_level = true
	sprite.global_position = Vector3(global_position.x, 0.001, global_position.z)
	sprite.rotation = Vector3(PI/2,PI,0)
	sprite.shaded = true
	sprite.pixel_size = .005
	add_child(sprite)
