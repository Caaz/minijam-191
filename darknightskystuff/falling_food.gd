extends Node3D

signal hit_the_ground

func _ready() -> void:
	#var material = $FloorIndicator.get_active_material(0)
	#$FloorIndicator.material_override = material
	#$FloorIndicator.material_override.albedo_color.a = 0.1
	#print($FloorIndicator.material_override.albedo_color)
	add_to_group("food")
	pass



func _on_area_3d_body_entered(body: Node3D) -> void:
	hit_the_ground.emit()
	queue_free()
	pass # Replace with function body.
