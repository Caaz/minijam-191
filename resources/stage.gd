class_name Stage extends Resource

## Time in seconds of how long this stage lasts.
@export var time:int
## Name of the stage to display to the player
@export var stage_name:String
## Speed of gravity for food
@export var gravity_scale:float = 1.0
## Rate at which food is spawned.
@export var spawn_time:float = 2.0
@export var music:AudioStream
@export var chance_of_multiple_spawn: float = 10
@export var max_multiple_spawn_num: int = 2
