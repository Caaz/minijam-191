class_name Path extends Path3D

@export var line:Line3D
@export var follower:PathFollow3D
@export var preview:PathFollow3D
## Points in local space
var points:Array[Vector3]
var tesselation_resolution = .25

func _ready():
	curve = Curve3D.new()
	preview.hide()

## Adds a point to the path, if that point is greater in distance than a specified distance.
func add_point(point:Vector3, force:bool=false, min_distance:float=tesselation_resolution):
	if not force and len(points) > 0 and points[-1].distance_to(point) < min_distance:
		return
	print("Adding point ",point)
	points.append(point)
	curve.add_point(point)
	if points.size() > 1:
		update_line_display()
		preview.show()
		preview.progress_ratio = 1.0

func update_line_display():
	var tesselated_line:Array[Vector3]
	var current_step = follower.progress / tesselation_resolution
	var steps:int = curve.get_baked_length() / tesselation_resolution
	for i:float in range(current_step, steps):
		tesselated_line.append(curve.sample_baked(float(i)*tesselation_resolution))
	line.points = tesselated_line
	line.rebuild()
