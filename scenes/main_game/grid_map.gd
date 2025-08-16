class_name CustomGridMap
extends GridMap

# Store the current square data
var current_square_center: Vector3i
var current_square_size: int = 0
var mesh_library_item_id: int = 0  # ID of the mesh item to use

# Dictionary to track which cells are part of our square
var square_cells: Dictionary = {}

func _ready():
	pass

# Creates a square filled from inside out
func create_square(center: Vector3i, size: int) -> void:
	if size <= 0:
		print("Square size must be positive")
		return

	# Clear existing square
	clear_current_square()

	# Update current square data
	current_square_center = center
	current_square_size = size
	square_cells.clear()

	# Calculate half size for positioning
	@warning_ignore("integer_division")
	var half_size:int = size / 2

	# Fill the square from inside out using a spiral/ring approach
	for ring:int in range(half_size + 1):
		fill_ring(center, ring)

# Fills a ring at the specified distance from center
func fill_ring(center: Vector3i, ring_distance: int) -> void:
	if ring_distance == 0:
		# Center cell
		var pos = center
		set_cell_item(pos, mesh_library_item_id)
		square_cells[pos] = true
		return

	@warning_ignore("integer_division")
	var half_size:int = current_square_size / 2

	# Calculate ring bounds
	var min_x:int = center.x - ring_distance
	var max_x:int = center.x + ring_distance
	var min_z:int = center.z - ring_distance
	var max_z:int = center.z + ring_distance

	# Only fill cells that are within the square bounds
	var square_min_x:int = center.x - half_size
	var square_max_x:int = center.x + half_size
	var square_min_z:int = center.z - half_size
	var square_max_z = center.z + half_size

	# Fill the ring
	for x in range(min_x, max_x + 1):
		for z in range(min_z, max_z + 1):
			# Check if this cell is on the ring perimeter and within square bounds
			var is_on_ring = (x == min_x or x == max_x or z == min_z or z == max_z)
			var is_within_square = (x >= square_min_x and x <= square_max_x and 
									z >= square_min_z and z <= square_max_z)

			if is_on_ring and is_within_square:
				var pos = Vector3i(x, center.y, z)
				set_cell_item(pos, mesh_library_item_id)
				square_cells[pos] = true

# Increases the square size by adding outer edges
func increase_square_size(amount: int = 1) -> void:
	if current_square_size <= 0:
		print("No square exists to resize")
		return

	if amount <= 0:
		print("Amount must be positive")
		return

	var old_size = current_square_size
	current_square_size += amount

	# Add new rings for the increased size
	@warning_ignore("integer_division")
	var half_old_size = old_size / 2
	@warning_ignore("integer_division")
	var half_new_size = current_square_size / 2

	# Fill the new outer rings
	for ring in range(half_old_size + 1, half_new_size + 1):
		fill_ring(current_square_center, ring)

# Decreases the square size by removing outer edges
func decrease_square_size(amount: int = 1) -> void:
	if current_square_size <= 0:
		print("No square exists to resize")
		return

	if amount <= 0:
		print("Amount must be positive")
		return

	if amount >= current_square_size:
		print("Cannot decrease square below size 1")
		amount = current_square_size - 1

	current_square_size -= amount

	@warning_ignore("integer_division")
	var half_new_size = current_square_size / 2

	# Remove cells that are now outside the new square bounds
	var cells_to_remove = []

	for pos in square_cells.keys():
		var distance_x = abs(pos.x - current_square_center.x)
		var distance_z = abs(pos.z - current_square_center.z)
		var max_distance = max(distance_x, distance_z)

		if max_distance > half_new_size:
			cells_to_remove.append(pos)

	# Remove the cells
	for pos in cells_to_remove:
		set_cell_item(pos, GridMap.INVALID_CELL_ITEM)
		square_cells.erase(pos)

# Clears the current square completely
func clear_current_square() -> void:
	for pos in square_cells.keys():
		set_cell_item(pos, GridMap.INVALID_CELL_ITEM)
	square_cells.clear()
	current_square_size = 0

# Sets the mesh library item ID to use for the square
func set_mesh_item_id(item_id: int) -> void:
	mesh_library_item_id = item_id

# Gets the current square information
func get_square_info() -> Dictionary:
	return {
		"center": current_square_center,
		"size": current_square_size,
		"cell_count": square_cells.size()
	}
