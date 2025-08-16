class_name Path extends Path3D

@export var line:Line3D
## Points in local space
var points:Array[Vector3]

## Adds a point to the path, if that point is greater in distance than a specified distance.
func add_point(point:Vector3, force:bool=false, min_distance:float=.5):
	if not force and len(points) > 0 and points[-1].distance_to(point) < min_distance:
		return
	print("Adding point ",point)
	points.append(point)
	curve.add_point(point)
	line.points.append(point)
	line.rebuild()
