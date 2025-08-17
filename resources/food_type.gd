class_name FoodType extends Resource

@export var mesh:Mesh:
	set(new_mesh):
		mesh = new_mesh
		collision_shape = mesh.create_convex_shape(true, true)

@export var icon:Texture2D
@export var name:String
@export var points:int = 1
@export var fall_speed:float = 1
@export var splats:bool = true
@export var explodes:bool = false
@export var collect_sounds: Array[AudioStream]
@export var impact_sound: AudioStream

var collision_shape:ConvexPolygonShape3D
