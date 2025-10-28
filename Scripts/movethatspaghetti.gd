extends CharacterBody2D
@onready var game_manager: Node = %GameManager

var dragging = false
var of = Vector2(0, 0)

func _physics_process(delta: float) -> void:
	if dragging:
		position = get_global_mouse_position() - of
	if not is_on_floor():
		velocity += get_gravity() * delta


func _on_button_button_down() -> void:
	dragging = true
	of = get_global_mouse_position() - global_position


func _on_button_button_up() -> void:
	dragging = false

func restart():
	queue_free()
