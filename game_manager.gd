extends Node

# --- Minigame data ---
var minigame_data = {
	"Homunculicious": "res://scenes/homuncu-licious.tscn",
	"Feed": "res://scenes/homuncu-feasting.tscn",
	"Clean": "res://scenes/homuncu-cleaning.tscn",
	"Guard": "res://scenes/homunc-employed.tscn",
}

# --- Queue and progress ---
var minigame_queue: Array = []
var current_index: int = 0

# --- Score tracking ---
var total_points: int = 0

func remove_from_queue(name: String):
	minigame_queue.erase(name)
	current_index = 0
	total_points = 0

func add_to_queue(name: String):
	if name in minigame_data:
		minigame_queue.append(name)
	else:
		push_warning("No scene found for '%s'" % name)

func start_queue():
	if minigame_queue.is_empty():
		push_warning("No games in queue!")
		return
	current_index = 0
	total_points = 0
	_play_next()

func report_minigame_finished(points_earned: int):
	total_points += points_earned
	current_index += 1
	_play_next()

func _play_next():
	if current_index >= minigame_queue.size():
		print("✅ All minigames done! Total points:", total_points)
		get_tree().change_scene_to_file("res://scenes/care_selection.tscn")
		return

	var name = minigame_queue[current_index]
	var path = minigame_data.get(name, "")
	if path != "":
		print("▶️ Loading:", name)
		get_tree().change_scene_to_file(path)
	else:
		push_error("Scene not found for %s" % name)
