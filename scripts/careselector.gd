extends Control

var hunger := 50
var happiness := 70
var energy := 80

@onready var hunger_label = $VBoxContainer/HungerLabel
@onready var happiness_label = $VBoxContainer/HappinessLabel
@onready var energy_label = $VBoxContainer/EnergyLabel

func _ready():
	update_stats()

func update_stats():
	hunger_label.text = "Hunger: %d" % hunger
	happiness_label.text = "Happiness: %d" % happiness
	energy_label.text = "Energy: %d" % energy

func _on_FeedButton_pressed():
	hunger += 10
	update_stats()

func _on_PlayButton_pressed():
	happiness += 10
	update_stats()

func _on_RestButton_pressed():
	energy += 10
	update_stats()

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_feed_button_pressed() -> void:
	pass # Replace with function body.


func _on_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_rest_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
