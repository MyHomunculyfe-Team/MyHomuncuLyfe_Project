extends Node2D

# --- Minigame Data (Name + Scene Path) ---
var minigame_data = {
	"Homunculicious": "res://scenes/homuncu-licious.tscn",
	"Feed": "res://scenes/homuncu-feasting.tscn",
	"Clean": "res://scenes/homuncu-cleaning.tscn",
	"Guard": "res://scenes/homunc-employed.tscn",
}

# --- Dynamic queue state ---
var minigame_queue: Array = []
var current_index: int = 0

# --- Cached nodes ---
@onready var queue_hbox = $UI/NavPanel/BottomScroll/QueueHBox
@onready var minigame_list = $UI/PanelContainer/ScrollContainer/MinigameList


func _ready():
	print("✅ Care Selection ready!")

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
			minigame_queue.append(game_name)
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
		minigame_queue.erase(game_name)


# =====================================================
# ▶️ PLAY BUTTON — Run queued minigames
# =====================================================
func _on_play_pressed():
	if minigame_queue.is_empty():
		print("⚠️ No minigames in queue!")
		return

	print("🎮 Starting queued minigames...")
	current_index = 0
	_play_next_minigame()


func _play_next_minigame():
	if current_index >= minigame_queue.size():
		print("✅ All minigames finished! Returning to Care Selection.")
		get_tree().change_scene_to_file("res://scenes/care_selection.tscn")
		return

	var current_game = minigame_queue[current_index]
	var path = minigame_data.get(current_game, "")
	print(path)
	if path != "":
		print("▶️ Loading:", current_game)
		get_tree().change_scene_to_file(path)
	else:
		print("⚠️ Scene not found for", current_game)
		
# =====================================================
# ⚙️ SETTINGS & BACK BUTTONS
# =====================================================
func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_back_button_pressed(): 
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")



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
