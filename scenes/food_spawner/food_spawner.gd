extends Node3D
var food_types:Array[FoodType]
@export var food_group:ResourceGroup

func _ready() -> void:
	food_group.load_all_into(food_types)
	print(food_types)
