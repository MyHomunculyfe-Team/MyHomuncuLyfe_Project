extends Node

# --- Minigame data ---
var minigame_data = {
	"Homuncu-feasting": "res://scenes/homuncu-feasting.tscn",
	"Homuncu-licious": "res://scenes/feed_game.tscn",
	"Homuncu-cleaning": "res://scenes/clean_game.tscn",
	"Guard": "res://scenes/homunc-employed.tscn",
}

# --- Queue and progress ---
var minigame_queue: Array = []
var current_index: int = 0

# --- Score tracking ---
var pet_name: String 
var happiness: int
var hunger: int
var hygine: int

func _ready():
	var data = SaveLoad.load()
	pet_name = data.get("Pet_name", "MUNC")
	happiness = data.get("Happiness", 50)
	hunger = data.get("Hunger", 50)
	hygine = data.get("Hygine", 50)


func add_happiness(points: int):
	happiness += points
	
	if happiness > 100:
		happiness = 100
	
	if happiness < 0:
		happiness = 0

func add_hunger(points: int):
	hunger += points
	
	if hunger > 100:
		hunger = 100
	
	if hunger < 0:
		hunger = 0
	
func add_hygine(points: int):
	hygine += points
	
	if hygine > 100:
		hygine = 100
	
	if hygine < 0:
		hygine = 0

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
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		return

	var name = minigame_queue[current_index]
	var path = minigame_data.get(name, "")
	if path != "":
		print("▶️ Loading:", name)
		get_tree().change_scene_to_file(path)
	else:
		push_error("Scene not found for %s" % name)
		
