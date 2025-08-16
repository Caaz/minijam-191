class_name Food extends RigidBody3D
signal hit_floor()

@export var type:FoodType
@export var mesh_instance:MeshInstance3D
@export var collision_shape:CollisionShape3D

var sprite:Sprite3D
var progress_circle:Sprite3D
var initial_height:float

func _ready() -> void:
	mesh_instance.mesh = type.mesh
	collision_shape.shape = type.collision_shape
	initial_height = global_position.y
	_place_sprite()
	_create_progress_circle()

func _place_sprite() -> void:
	sprite = Sprite3D.new()
	sprite.texture = type.icon
	sprite.top_level = true
	sprite.position = Vector3(global_position.x, 0.001, global_position.z)
	sprite.rotation = Vector3(PI/2,0,0)
	sprite.shaded = true
	sprite.pixel_size = .005
	add_child(sprite)

func _create_progress_circle() -> void:
	# Create a circular progress indicator
	progress_circle = Sprite3D.new()

	# Create a circular texture programmatically
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw initial empty circle outline
	_draw_circle_progress(image, 0.0)

	var texture = ImageTexture.new()
	texture.set_image(image)
	progress_circle.texture = texture

	progress_circle.top_level = true
	progress_circle.position = Vector3(global_position.x, 0.002, global_position.z)
	progress_circle.rotation = Vector3(PI/2, 0, 0)
	progress_circle.pixel_size = .024
	progress_circle.modulate = Color.GREEN
	add_child(progress_circle)

func _draw_circle_progress(image: Image, progress: float) -> void:
	var center = Vector2(32, 32)
	var radius = 28
	var thickness = 4

	# Clear the image
	image.fill(Color.TRANSPARENT)

	# Draw progress arc
	var angle_span = progress * 2 * PI
	for angle in range(0, int(angle_span * 100)):
		var a = angle / 100.0 - PI/2  # Start from top
		for r in range(radius - thickness, radius + thickness):
			var x = int(center.x + cos(a) * r)
			var y = int(center.y + sin(a) * r)
			if x >= 0 and x < 64 and y >= 0 and y < 64:
				image.set_pixel(x, y, Color.WHITE)

func _physics_process(_delta) -> void:
	# Update progress circle based on height
	var current_height = global_position.y
	var progress = 1.0 - clamp(current_height / initial_height, 0.0, 1.0)

	# Update the progress circle texture
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	_draw_circle_progress(image, progress)

	var texture = ImageTexture.new()
	texture.set_image(image)
	progress_circle.texture = texture

	# Update positions
	sprite.position = Vector3(global_position.x, 0.001, global_position.z)
	progress_circle.position = Vector3(global_position.x, 0.002, global_position.z)

	# Check for floor collision
	var bodies:Array[Node3D] = get_colliding_bodies()
	if bodies.size() > 0:
		if bodies[0].is_in_group(&"floor"):
			hit_floor.emit()
			queue_free()
