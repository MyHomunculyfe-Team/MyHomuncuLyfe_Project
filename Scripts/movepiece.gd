extends Area2D

var dragging = false
var of = Vector2(0, 0)
@onready var game_manager: Node = %GameManager

func _process(delta):
	if dragging:
		position = get_global_mouse_position() - of

func _on_button_button_down():
	dragging = true
	of = get_global_mouse_position() - global_position


func _on_button_button_up():
	dragging = false

func _on_body_entered(body: Node2D) -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	queue_free()
