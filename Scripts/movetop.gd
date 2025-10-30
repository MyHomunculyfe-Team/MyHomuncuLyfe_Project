extends Area2D
#@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
#@onready var button: Button = $Button
#@onready var sprite_2d: Sprite2D = $Sprite2D

var dragging = false
var of = Vector2(0, 0)
#var scene = preload("res://Scenes/bottomMeat.tscn")
@onready var game_manager: Node = %GameManager
@onready var area_2d_6: Area2D = %Area2D6

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
	area_2d_6.flee()
	queue_free()
	#var instance = scene.instantiate()
	#add_child(instance)
	#sprite_2d.queue_free()
	#button.queue_free()
	#collision_shape_2d.queue_free()
