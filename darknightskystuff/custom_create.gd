extends CharacterBody3D

var target_location: Vector3

@export var speed: float = 10.0

@onready var pickup_area: Area3D = get_node_or_null("PickupArea")

func _ready() -> void:
	if pickup_area:
		pickup_area.area_entered.connect(_on_area_entered)
		pickup_area.body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area3D) -> void:
	_try_consume_food(area)

func _on_body_entered(body: Node3D) -> void:
	_try_consume_food(body)

func _physics_process(delta: float) -> void:
	if target_location:
		if global_position.distance_to(target_location) > 0.1:
			velocity = global_position.direction_to(target_location) * 10
		else:
			velocity = Vector3.ZERO
	move_and_slide()

pass

func _try_consume_food(node: Object) -> void:
	
	if node == null:
		return

	var food_root: Node = null

	# If we touched an Area3D on the food, its parents parent is likely the food root
	if node is Area3D:
		food_root = (node as Area3D).get_parent().get_parent()

	# Only consume nodes that are explicitly in the "food" group to avoid false positives.
	if food_root and food_root.is_in_group("food"):
		food_root.queue_free()
		emit_signal("food_captured", 1)
		print("Captured food!")
