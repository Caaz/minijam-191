extends Area3D
@export var cost_label:Label3D

func _ready():
	mouse_entered.connect(cost_label.show)
	mouse_exited.connect(cost_label.hide)
