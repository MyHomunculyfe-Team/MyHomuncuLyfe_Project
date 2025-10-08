extends Control

# --- Minigame Data (Name + Cost) ---
var minigame_data = {
	"Homunculicious": 1,
	"Feed": 3,
	"Clean": 1,
	"Guard": 2,
}

# --- Dynamic queue state ---
var minigame_queue: Array = []

# --- Cached node references ---
@onready var queue_hbox = $MarginContainer/MainBoxContainer/QueueContainer/BottomScroll/QueueHBox
@onready var minigame_list = $MarginContainer/MainBoxContainer/ScrollContainer/MinigameList
@onready var total_cost_label = $MarginContainer/MainBoxContainer/QueueContainer/TotalCostLabel

func _ready():
	# Label setup for minigames
	for button in minigame_list.get_children():
		var game_name = button.name.replace("_Button", "")
		var cost = minigame_data.get(game_name, 1)
		button.text = "%s  (💰%d)" % [game_name, cost]

	for button in queue_hbox.get_children():
		button.text = ""
		button.disabled = true

	_update_total_cost()


# =====================================================
# 📜 MENU BUTTONS — Add minigame to queue
# =====================================================
func _on_Homunculicious_Button_pressed(): _add_to_queue("Homunculicious")
func _on_Feed_Button_pressed(): _add_to_queue("Feed")
func _on_Clean_Button_pressed(): _add_to_queue("Clean")
func _on_Guard_Button_pressed(): _add_to_queue("Guard")

func _add_to_queue(game_name: String):
	# Find the first empty slot in queue
	for button in queue_hbox.get_children():
		if button.text == "":
			var cost = minigame_data.get(game_name, 1)
			button.text = "%s  (💰%d)" % [game_name, cost]
			button.disabled = false
			minigame_queue.append({"name": game_name, "cost": cost})
			print("Added:", game_name, "Cost:", cost)
			_update_total_cost()
			return
	print("⚠️ Queue full! Remove one to add new.")


# =====================================================
# 🎯 QUEUE BUTTONS — Remove from queue dynamically
# =====================================================
func _on_Queue_button_pressed(button: Button):
	if button.text != "":
		var game_name = button.text.split("  ")[0]
		print("Removed:", game_name)
		button.text = ""
		button.disabled = true
		
		for entry in minigame_queue:
			if entry.name == game_name:
				minigame_queue.erase(entry)
				break
		
		_update_total_cost()


# =====================================================
# 💰 TOTAL COST — Update display
# =====================================================
func _update_total_cost():
	var total = 0
	for entry in minigame_queue:
		total += entry.cost
	total_cost_label.text = "Total Cost: %d" % total


# =====================================================
# ▶️ PLAY BUTTON — Run queued minigames
# =====================================================
func _on_Play_pressed():
	if minigame_queue.is_empty():
		print("⚠️ No minigames in queue!")
		return
	
	print("🎮 Starting queued minigames:")
	for game in minigame_queue:
		print("- %s (Cost: %d)" % [game.name, game.cost])

	# After playing, clear everything
	minigame_queue.clear()
	for button in queue_hbox.get_children():
		button.text = ""
		button.disabled = true
	
	_update_total_cost()


# =====================================================
# ⚙️ SETTINGS BUTTON — Navigate to settings screen
# =====================================================
func _on_SettingsButton_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
