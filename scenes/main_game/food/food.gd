class_name Food extends RigidBody3D
signal hit_floor()

@export var type:FoodType
@export var mesh_instance:MeshInstance3D
@export var collision_shape:CollisionShape3D
@export var drop_indicator:Sprite3D

var sprite:Sprite3D
var progress_circle:Sprite3D
var initial_height:float
var drop_material:ShaderMaterial

func _ready() -> void:
	mesh_instance.mesh = type.mesh
	collision_shape.shape = type.collision_shape
	initial_height = global_position.y
	drop_indicator.material_override = drop_indicator.material_override.duplicate(true)
	drop_indicator.position = Vector3(global_position.x, 0.001, global_position.z)
	drop_material = drop_indicator.material_override as ShaderMaterial
	drop_material.set_shader_parameter('icon', type.icon)

func _physics_process(_delta) -> void:
	# Update progress circle based on height
	var current_height = global_position.y
	var progress = 1.0 - clamp(global_position.y / initial_height, 0.0, 1.0)
	drop_material.set_shader_parameter('amount', progress)

	# Check for floor collision
	var bodies:Array[Node3D] = get_colliding_bodies()
	if bodies.size() > 0:
		if bodies[0].is_in_group(&"floor"):
			hit_floor.emit()
			queue_free()
