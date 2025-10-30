extends Node2D

# --- Cached nodes ---
@onready var queue_hbox = $UI/NavPanel/BottomScroll/QueueHBox
@onready var minigame_list = $UI/PanelContainer/ScrollContainer/MinigameList


func _ready():
	# connect minigame buttons
	for button in minigame_list.get_children():
		var game_name = button.name.replace("_Button", "")
		button.text = game_name
		button.connect("pressed", Callable(self, "_on_minigame_pressed").bind(game_name))

	# connect queue buttons
	for button in queue_hbox.get_children():
		button.text = ""
		button.disabled = true
		button.connect("pressed", Callable(self, "_on_queue_button_pressed").bind(button))

# =====================================================
# 📜 MENU BUTTONS — Add minigame to queue
# =====================================================
func _on_minigame_pressed(game_name: String):
	for button in queue_hbox.get_children():
		if button.text == "":
			button.text = game_name
			button.disabled = false
			GameManager.add_to_queue(game_name)
			print("✅ Added:", game_name)
			return
	print("⚠️ Queue full! Remove one to add new.")


# =====================================================
# 🎯 QUEUE BUTTONS — Remove from queue dynamically
# =====================================================
func _on_queue_button_pressed(button: Button):
	if button.text != "":
		var game_name = button.text
		print("🗑️ Removed:", game_name)
		button.text = ""
		button.disabled = true
		GameManager.remove_from_queue(game_name)

# =====================================================
# ▶️ PLAY BUTTON — Run queued minigames
# =====================================================
func _on_play_pressed():
	GameManager.start_queue()
	
# =====================================================
# ⚙️ SETTINGS & BACK BUTTONS
# =====================================================
func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_back_button_pressed(): 
	get_tree().change_scene_to_file("res://scenes/Main.tscn")



func _on_homunculicious_button_pressed() -> void:
	pass # Replace with function body.


func _on_feed_button_pressed() -> void:
	pass # Replace with function body.


func _on_clean_button_pressed() -> void:
	pass # Replace with function body.


func _on_guard_button_pressed() -> void:
	pass # Replace with function body.


func _on_button_pressed():
	pass # Replace with function body.


func _on_button_2_pressed():
	pass # Replace with function body.



func _on_button_3_pressed():
	pass # Replace with function body.


func _on_button_4_pressed():
	pass # Replace with function body.
