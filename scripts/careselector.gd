extends Node2D

# --- Minigame Data (Name + Scene Path) ---
var minigame_data = {
	"Homunculicious": "res://scenes/homunculicious.tscn",
	"Feed": "res://scenes/feed.tscn",
	"Clean": "res://scenes/clean.tscn",
	"Guard": "res://scenes/guard.tscn",
}

# --- Dynamic queue state ---
var minigame_queue: Array = []

# --- Cached node references ---
@onready var queue_hbox = $UI/NavPanel/BottomScroll/QueueHBox
@onready var minigame_list = $UI/PanelContainer/ScrollContainer/MinigameList

func _ready():
	for button in minigame_list.get_children():
		var game_name = button.name.replace("_Button", "")
		button.text = game_name

	for button in queue_hbox.get_children():
		button.text = ""
		button.disabled = true


# =====================================================
# 📜 MENU BUTTONS — Add minigame to queue
# =====================================================
func _on_Homunculicious_Button_pressed(): _add_to_queue("Homunculicious")
func _on_Feed_Button_pressed(): _add_to_queue("Feed")
func _on_Clean_Button_pressed(): _add_to_queue("Clean")
func _on_Guard_Button_pressed(): _add_to_queue("Guard")

func _add_to_queue(game_name: String):
	for button in queue_hbox.get_children():
		if button.text == "":
			button.text = game_name
			button.disabled = false
			minigame_queue.append(game_name)
			print("Added:", game_name)
			return
	print("⚠️ Queue full! Remove one to add new.")


# =====================================================
# 🎯 QUEUE BUTTONS — Remove from queue dynamically
# =====================================================
func _on_Queue_button_pressed(button: Button):
	if button.text != "":
		var game_name = button.text
		print("Removed:", game_name)
		button.text = ""
		button.disabled = true
		minigame_queue.erase(game_name)


# =====================================================
# ▶️ PLAY BUTTON — Run queued minigames
# =====================================================
func _on_Play_pressed():
	if minigame_queue.is_empty():
		print("⚠️ No minigames in queue!")
		return

	print("🎮 Starting queued minigames...")

	# Load the first minigame in the queue
	var first_game = minigame_queue[0]
	var path = minigame_data.get(first_game, "")
	
	if path != "":
		get_tree().change_scene_to_file(path)
	else:
		print("⚠️ Scene not found for", first_game)


func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_back_button_pressed(): 
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
