extends Node2D

# =====================================================
# JOBSELECTOR SCRIPT (No Cost Version)
# =====================================================

# Job name → Scene path
var job_data = {
	"Homunculicious": "res://scenes/homuncu-licious.tscn",
	"Feed": "res://scenes/homuncu-feasting.tscn",
	"Clean": "res://scenes/homuncu-cleaning.tscn",
	"Guard": "res://scenes/homuncu-feasting.tscn",
}

# Track queued jobs
var job_queue: Array = []

# Cached node references
@onready var queue_hbox = $UI/NavPanel/BottomScroll/QueueHBox
@onready var minigame_list = $UI/PanelContainer/ScrollContainer/MinigameList


# =====================================================
# READY
# =====================================================
func _ready():
	# Set top list button text dynamically
	for button in minigame_list.get_children():
		var job_name = button.name.replace("_Button", "")
		button.text = job_name

	# Initialize empty queue slots
	for button in queue_hbox.get_children():
		button.text = ""
		button.disabled = true


# =====================================================
# ADD TO QUEUE (Top buttons)
# =====================================================
func _on_Homunculicious_Button_pressed(): _add_to_queue("Homunculicious")
func _on_Feed_Button_pressed(): _add_to_queue("Feed")
func _on_Clean_Button_pressed(): _add_to_queue("Clean")
func _on_Guard_Button_pressed(): _add_to_queue("Guard")

func _add_to_queue(job_name: String):
	for button in queue_hbox.get_children():
		if button.text == "":
			button.text = job_name
			button.disabled = false
			job_queue.append(job_name)
			return
	print("⚠️ Queue full! Remove one first.")


# =====================================================
# REMOVE FROM QUEUE (Bottom buttons)
# =====================================================
func _on_Queue_button_pressed(button: Button):
	if button.text != "":
		var job_name = button.text
		button.text = ""
		button.disabled = true
		job_queue.erase(job_name)


# =====================================================
# PLAY BUTTON FUNCTIONALITY
# =====================================================
func _on_Play_pressed():
	if job_queue.is_empty():
		print("⚠️ No jobs selected!")
		return

	print("🎮 Starting queued jobs:")
	_play_next_job()


func _play_next_job():
	if job_queue.is_empty():
		# Finished all jobs — clear buttons
		for button in queue_hbox.get_children():
			button.text = ""
			button.disabled = true
		print("✅ All jobs completed!")
		return

	var next_job = job_queue.pop_front()
	var scene_path = job_data[next_job]

	if ResourceLoader.exists(scene_path):
		print("▶️ Loading job:", next_job)
		var next_scene = load(scene_path)
		get_tree().change_scene_to_packed(next_scene)
	else:
		print("⚠️ Scene not found for:", next_job)
		_play_next_job()


# =====================================================
# NAVIGATION BUTTONS
# =====================================================
func _on_SettingsButton_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
