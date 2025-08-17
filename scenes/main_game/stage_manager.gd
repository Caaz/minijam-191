class_name StageManager extends Node

signal stage_changed(level: int, stage: Stage)

@export var stages:Array[Stage]
@export var game:MainGame
@export var background_music:AudioStreamPlayer
var stage:Stage:
	set(new_stage):
		stage = new_stage
		_stage_time_remaining = stage.time
		stage_changed.emit(_level, stage)
		$"../MusStinger".play()
		var was_playing:bool = background_music.playing
		if background_music.stream != stage.music:
			background_music.stream = stage.music
			if was_playing:
				background_music.play()

var _level:int = -1:
	set(new_index):
		_level = new_index
		stage = stages[_level % stages.size()]

var _stage_time_remaining:int = 0:
	set(new_time):
		_stage_time_remaining = new_time
		if _stage_time_remaining <= 0:
			_level += 1

func _ready() -> void:
	game.seconds_changed.connect(func(_seconds:float) -> void:
		_stage_time_remaining -= 1
	)

func reset():
	_stage_time_remaining = 0
	_level = 0
