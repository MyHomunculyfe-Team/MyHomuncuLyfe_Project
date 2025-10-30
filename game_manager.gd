extends Node

# --- Minigame data ---
var minigame_data = {
	"Homuncu-feasting": "res://Scenes/homuncu-feasting.tscn",
	"Homuncu-licious": "res://Scenes/feed_game.tscn",
	"Homuncu-cleaning": "res://Scenes/clean_game.tscn",
	"Homunc-employed": "res://Scenes/JobGame.tscn",
}

# --- Queue and progress ---
var minigame_queue: Array = []
var current_index: int = 0

signal stats_changed 
signal deformity_warning(stat_name: String)

# Pet data
var pet_name: String 
var happiness: int
var hunger: int
var hygiene: int

var deformity_triggered := {
	"happiness": false,
	"hunger": false,
	"hygiene": false
}

func _ready():
	var data = SaveLoad.load()
	pet_name = data.get("Pet_name", "MUNC")
	happiness = data.get("Happiness", 50)
	hunger = data.get("Hunger", 50)
	hygiene = data.get("Hygiene", 50)
	

		
func add_value(field: String, delta: float) -> void:
	# Get the current stat
	var current_value: float = get(field)
	
	# Add the delta (change amount)
	var new_value: float = clamp(current_value + delta, 0, 100)
	
	# Only do something if it actually changed
	if new_value != current_value:
		set(field, new_value)
		stats_changed.emit()
		_check_deformity(field, new_value)
	
		
func _check_deformity(field: String, value: int) -> void:
	# trigger warning only once when value crosses the threshold
	if value <= 10 and not deformity_triggered[field]:
		deformity_triggered[field] = true
		deformity_warning.emit(field)
	elif value > 10:
		# reset trigger once the stat returns to safe range
		deformity_triggered[field] = false

func remove_from_queue(name: String):
	minigame_queue.erase(name)
	current_index = 0

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
	_play_next()

func report_minigame_finished():
	current_index += 1
	_play_next()

func _play_next():
	if current_index >= minigame_queue.size():
		if get_tree():
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
			minigame_queue.clear()
		return

	var name = minigame_queue[current_index]
	var path = minigame_data.get(name, "")
	if path != "":
		print("▶️ Loading:", name)
		if get_tree():
			get_tree().change_scene_to_file(path)
	else:
		push_error("Scene not found for %s" % name)
		
