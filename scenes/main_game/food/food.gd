class_name Food extends RigidBody3D
signal hit_floor()

@export var type:FoodType
@export var mesh_instance:MeshInstance3D
@export var collision_shape:CollisionShape3D
@export var drop_indicator:Sprite3D
@export var explosion:GPUParticles3D

var sprite:Sprite3D
var progress_circle:Sprite3D
var initial_height:float
var drop_material:ShaderMaterial


func _ready() -> void:
	mesh_instance.mesh = type.mesh
	collision_shape.shape = type.collision_shape
	initial_height = global_position.y
	drop_indicator.material_override = drop_indicator.material_override.duplicate(true)
	drop_indicator.position = Vector3(global_position.x, 0.5, global_position.z)
	drop_material = drop_indicator.material_override as ShaderMaterial
	drop_material.set_shader_parameter('icon', type.icon)

func _physics_process(_delta) -> void:
	# Update progress circle based on height
	if drop_indicator:
		var progress = 1.0 - clamp(global_position.y / initial_height, 0.0, 1.0)
		drop_material.set_shader_parameter('amount', progress)

	var bodies:Array[Node3D] = get_colliding_bodies()
	for body:Node3D in bodies:
		if body.is_in_group(&"floor"):
			if type.splats:
				queue_free()
				hit_floor.emit()
			elif drop_indicator:
				drop_indicator.queue_free()
		
		if type.explodes and body is Crate:
			body.destroy()
			explode()
	
func explode() -> void:
	explosion.emitting = true
	mesh_instance.hide()
	explosion.finished.connect(queue_free)
