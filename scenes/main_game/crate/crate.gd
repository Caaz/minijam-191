class_name Crate extends RigidBody3D
signal selected()
signal caught(food:Food)
@export var PathScene:PackedScene
@export var selection_ui:Sprite3D
@export var catching_area:Area3D

var path:Path
var speed:float = 10

var is_selected:bool = false:
	set(new_selected):
		is_selected = new_selected
		if is_selected:
			selection_ui.show()
			selected.emit()
		else:
			selection_ui.hide()

func _ready() -> void:
	catching_area.body_entered.connect(func(body:Node3D):
		var food:Food = body as Food
		if not food:
			return
		
		caught.emit(food)
		food.queue_free()
	)

func _input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed(&"select"):
		is_selected = true

## Creates a new path, removing the old one if it exists.
func new_path() -> void:
	if path:
		path.queue_free()
	
	path = PathScene.instantiate() as Path
	add_child(path)
	path.add_point(global_position)

func _physics_process(delta:float) -> void:
	if not path or path.points.size() <= 1:
		return
	
	var target:Vector3 = position
	path.follower.progress += delta * speed
	target = path.follower.global_position
	path.update_line_display()
	position = target
	if not is_selected and is_equal_approx(path.follower.progress_ratio, 1.0):
		path.queue_free()
