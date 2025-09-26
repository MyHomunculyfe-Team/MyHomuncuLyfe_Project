extends Area2D
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"

@onready var game_manager: Node = %GameManager

func _on_body_entered(body: Node2D) -> void:
	game_manager.add_score()
	character_body_2d.restart()
