class_name Crate extends RigidBody3D
signal selected()

@export var selection_ui:Sprite3D
var path:Path

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

func add_path(new_path:Path):
	add_child(new_path)
	path = new_path
