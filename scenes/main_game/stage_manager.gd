class_name StageManager
extends Node

signal stage_changed(new_stage: int, description: String)

@export var stage_duration: float = 3.0  # Duration of each stage in seconds
@export var config_file_path: String = "res://stage_config.json"

var current_stage: int = 0
var stage_timer: Timer
var elapsed_time: float = 0.0
var stage_configs: Dictionary = {}
var default_config: Dictionary = {
							 "spawn_interval": 2.0,
							 "spawn_interval_decrease": 0.1,  # How much to decrease spawn interval per stage
							 "min_spawn_interval": 0.3,
							 "gravity_scale": 0.5,
							 "gravity_scale_increase": 0.1,  # How much to increase gravity per stage
							 "max_gravity_scale": 2.0,
							 "description": "Stage {stage}"
						 }

func _ready() -> void:
	_setup_timer()
	_load_stage_config()
	_apply_stage_settings(0)

func _setup_timer() -> void:
	stage_timer = Timer.new()
	stage_timer.wait_time = stage_duration
	stage_timer.timeout.connect(_advance_stage)
	stage_timer.autostart = true
	add_child(stage_timer)

func _load_stage_config() -> void:
	if FileAccess.file_exists(config_file_path):
		var file = FileAccess.open(config_file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.get_data()
				if data.has("default_config"):
					default_config.merge(data.default_config, true)
				if data.has("stage_configs"):
					stage_configs = data.stage_configs
				if data.has("stage_duration"):
					stage_duration = data.stage_duration
					stage_timer.wait_time = stage_duration
			else:
				print("Error parsing stage config JSON")

func _advance_stage() -> void:
	current_stage += 1
	elapsed_time += stage_duration
	var config = _get_stage_config(current_stage)
	_apply_stage_settings(current_stage)

	var description = config.description
	if "{stage}" in description:
		description = description.replace("{stage}", str(current_stage))

	stage_changed.emit(current_stage, description)
	print("Advanced to stage: ", current_stage, " - ", description)

func _apply_stage_settings(stage: int) -> void:
	var config = _get_stage_config(stage)

	# Update food spawner with new settings
	_update_food_spawner(config.spawn_interval, config.gravity_scale)

func _get_stage_config(stage: int) -> Dictionary:
	var stage_key = str(stage)

	if stage_configs.has(stage_key):
		# Custom stage configuration
		var custom_config = default_config.duplicate()
		custom_config.merge(stage_configs[stage_key], true)
		return custom_config
	else:
		# Linear scaling for non-custom stages
		var config = default_config.duplicate()
		var new_spawn_interval = config.spawn_interval - (stage * config.spawn_interval_decrease)
		config.spawn_interval = max(new_spawn_interval, config.min_spawn_interval)

		var new_gravity_scale = config.gravity_scale + (stage * config.gravity_scale_increase)
		config.gravity_scale = min(new_gravity_scale, config.max_gravity_scale)

		return config

func _update_food_spawner(spawn_interval: float, gravity_scale: float) -> void:
	# Find food spawner and update its settings
	var food_spawner = get_tree().get_first_node_in_group("food_spawner")
	if food_spawner and food_spawner.has_method("update_spawn_settings"):
		food_spawner.update_spawn_settings(spawn_interval, gravity_scale)

# Public methods for external access
func get_current_stage() -> int:
	return current_stage

func get_elapsed_time() -> float:
	return elapsed_time + (stage_duration - stage_timer.time_left)

func get_current_stage_config() -> Dictionary:
	return _get_stage_config(current_stage)

func reset_stages() -> void:
	current_stage = 0
	elapsed_time = 0.0
	stage_timer.start(stage_duration)
	var config = _get_stage_config(0)
	_apply_stage_settings(0)

	var description = config.description
	if "{stage}" in description:
		description = description.replace("{stage}", str(0))

	stage_changed.emit(0, description)
