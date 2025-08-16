class_name MainGame extends Node3D
signal score_changed(score:int)

@export var CrateScene:PackedScene
@export var camera:Camera3D
## This node handles raycasts for clicks, because I don't want to bother with managing all the raycast code for doing this manually.
@export var click_raycast:RayCast3D

## Current selected crate
var selected_crate:Crate

var score:int:
	set(new_score):
		score = new_score
		score_changed.emit(score)

func _ready() -> void:
	add_crate()

func add_crate() -> void:
	var crate:Crate = CrateScene.instantiate() as Crate
	crate.selected.connect(_on_crate_selected.bind(crate))
	add_child(crate)

func _on_crate_selected(crate:Crate):
	print("crate selected ", crate)
	selected_crate = crate
	selected_crate.new_path()
	# Probably don't even need to do this with the new method, but just in case it's here...
	#for crate_node in get_tree().get_nodes_in_group(&'crate'):
		#if crate_node == crate:
			#continue
		#crate_node.selected = false

func _input(event:InputEvent):
	
	if not selected_crate:
		return
		
	if event.is_action_released(&"select"):
		selected_crate.is_selected = false
		selected_crate = null
		return

	var mouse_event:InputEventMouseMotion = event as InputEventMouseMotion
	if not mouse_event:
		return
	
		
	click_raycast.position = camera.project_ray_origin(mouse_event.position)
	click_raycast.target_position = camera.project_ray_normal(mouse_event.position) * 100
	click_raycast.force_raycast_update()
	if not click_raycast.is_colliding():
		return
		
	selected_crate.path.add_point(click_raycast.get_collision_point())
