extends Area2D
@onready var game_manager: Node = %GameManager
@onready var homunc: CharacterBody2D = %Homunc

func _on_body_entered(body: Node2D) -> void:
	game_manager.add_score()
	game_manager.lose_life()
	homunc.restart()
	
	
