@tool
class_name SliderInput extends BoxContainer
signal value_changed(value:float)

@export var text:String:
	set(new_text):
		text = new_text
		_label.text = text
		
@export_range(0.0, 1.0, 0.001) var value:float:
	set(new_value):
		if value == new_value:
			return
		value = new_value
		value_changed.emit(value)
		if _slider and _slider.value != value:
			_slider.value = value

@export var _slider:HSlider
@export var _label:Label

func _ready() -> void:
	_slider.value_changed.connect(func(new_value):
		value = new_value
	)
