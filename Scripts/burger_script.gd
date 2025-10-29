extends Area2D

var dragging = false
var of = Vector2(0, 0)
func _process(delta):
	if dragging:
		position = get_global_mouse_position() - of
@onready var game_manager: Node = %GameManager

func _on_button_button_down():
	dragging = true
	of = get_global_mouse_position() - global_position

func flee():
	position = Vector2(10, 10)
	
func _on_button_button_up():
	dragging = false

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	game_manager.add_score()
