extends Area2D
@onready var homunc: CharacterBody2D = %Homunc
@onready var game_manager: Node = %GameManager

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	Engine.time_scale = 0.5
	timer.start()
	game_manager.lose_life()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	homunc.restart()
