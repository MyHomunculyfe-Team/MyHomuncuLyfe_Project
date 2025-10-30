extends Control

func _ready():
	pass


func _on_jobs_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/jobselector.tscn")


func _on_care_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/careselector.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
