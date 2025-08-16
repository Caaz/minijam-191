class_name Crate extends RigidBody3D
signal selected()

@export var PathScene:PackedScene
@export var selection_ui:Sprite3D
@export var pid:PIDController
var path:Path
var speed:float = 250

var is_selected:bool = false:
	set(new_selected):
		is_selected = new_selected
		if is_selected:
			selection_ui.show()
			selected.emit()
		else:
			selection_ui.hide()

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	if event.is_action_pressed(&"select"):
		is_selected = true

func new_path():
	if path:
		path.queue_free()
	
	path = PathScene.instantiate() as Path
	add_child(path)
	path.add_point(global_position)

func _physics_process(delta:float) -> void:
	if is_selected or not path:
		pid.target = position
		return
	if path.points.size() <= 1:
		path.queue_free()
		return
	path.follower.progress += delta * 5
	pid.target = path.follower.global_position
