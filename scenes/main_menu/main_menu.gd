class_name MainMenu extends Control

@export var play_button:Button
@export var sfx_setting:SliderInput
@export var music_setting:SliderInput

func _ready() -> void:
	sfx_setting.value_changed.connect(_update_audio_nodes.bind(&"sfx"))
	music_setting.value_changed.connect(_update_audio_nodes.bind(&"music"))
	_update_audio_nodes(sfx_setting.value, &"sfx")
	_update_audio_nodes(music_setting.value, &"music")
	
func _update_audio_nodes(volume_linear:float, group:StringName):
	# For some reason at least for me, .5 - 1. sound fairly similar in volume and I imagine this is a real life physics thing.
	volume_linear /= 2
	var audio_nodes:Array[Node] = get_tree().get_nodes_in_group(group)
	for node in audio_nodes:
		var audio = node as AudioStreamPlayer
		if not audio:
			continue
		audio.volume_linear = volume_linear
