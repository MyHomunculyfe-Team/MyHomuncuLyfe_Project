extends Control

# 🧩 References to nodes
@onready var minigame_list = $MarginContainer/MainBoxContainer/ScrollContainer/MinigameList
@onready var queue_list = $MarginContainer/MainBoxContainer/QueueContainer/BottomScroll/QueueHBox
@onready var play_button = $MarginContainer/MainBoxContainer/QueueContainer/Play
@onready var settings_button = $MarginContainer/MainBoxContainer/TopBar/SettingsButton

# 🧠 Data
var queue = []   # Stores the names of queued minigames

# Called when the scene is ready
func _ready():
	# Connect minigame buttons
	for button in minigame_list.get_children():
		button.connect("pressed", Callable(self, "_on_minigame_selected").bind(button))

	# Connect Play and Settings buttons
	play_button.connect("pressed", Callable(self, "_on_play_pressed"))
	settings_button.connect("pressed", Callable(self, "_on_settings_button_pressed"))

	print("Care Selection Ready!")

# 🔹 Step 1: Add minigame to queue when clicked
func _on_minigame_selected(button):
	if queue.size() >= 4:
		print("Queue full! Can't add more.")
		return

	# Prevent duplicate minigames
	if button.name in queue:
		print("Already in queue.")
		return

	var clone = button.duplicate()
	clone.text = button.text
	clone.connect("pressed", Callable(self, "_on_queue_button_pressed").bind(clone))

	queue_list.add_child(clone)
	queue.append(button.name)
	print("Added to queue:", queue)

# 🔹 Step 2: Remove from queue when clicked (and return to selection)
func _on_queue_button_pressed(button):
	queue_list.remove_child(button)
	queue.erase(button.name)
	button.queue_free()
	print("Removed from queue:", queue)

# 🔹 Step 3: Play button (for now just prints)
func _on_play_pressed():
	if queue.size() == 0:
		print("Queue empty! Nothing to play.")
	else:
		print("Starting queued minigames:", queue)
		# TODO: Load and play minigame scenes one by one here

# 🔹 Step 4: Settings button navigation
func _on_settings_button_pressed():
	print("Navigating to settings screen...")
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
