extends CharacterBody2D

@export var max_fill: int = 4
var fill_state: int = 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

#on ready 
func _ready():
	#check if food item touches body
	area.body_entered.connect(_on_body_entered)
	#update the fill visuals to represent the initial fill state
	_update_skin()

#When food touches body
func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("Food"):
		if fill_state < max_fill:
			fill_state += 1
			_update_skin()


func _update_skin():
		sprite.frame = fill_state
