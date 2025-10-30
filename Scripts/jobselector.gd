extends Control

# Cleaning job
func _on_CleaningButton_pressed():
	get_tree().change_scene_to_file("res://scenes/clean_game.tscn")

# Cooking job
func _on_CookingButton_pressed():
	get_tree().change_scene_to_file("res://scenes/feed_game.tscn")

# Guarding job
func _on_GuardingButton_pressed():
	get_tree().change_scene_to_file("res://scenes/killzone.tscn")

# Go back to Main Menu
func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_cleaning_button_pressed() -> void:
	pass # Replace with function body.


func _on_cooking_button_pressed() -> void:
	pass # Replace with function body.


func _on_guarding_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
