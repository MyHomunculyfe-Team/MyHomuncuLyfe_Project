extends Node

var GameManager := preload("res://game_manager.gd")
var gm: Node

func _ready():
	print("Running GameManager tests...")

	test_happiness_clamp()
	test_hunger_clamp()
	test_hygine_clamp()
	test_add_to_queue()
	test_remove_from_queue()
	test_report_minigame_finished()
	test_start_queue_empty()
	test_play_next_invalid_scene()

	print("All tests finished!")

# Helper function
func check(condition: bool, test_name: String):
	if condition:
		print("✅ ", test_name)
	else:
		print("❌ ", test_name)

# Setup a fresh GameManager instance before each test
func _before_each():
	gm = GameManager.new()
	gm.pet_name = "TestPet"
	gm.happiness = 50
	gm.hunger = 50
	gm.hygine = 50
	gm.minigame_queue.clear()
	gm.current_index = 0

# -----------------------
# Stats Tests
# -----------------------
func test_happiness_clamp():
	_before_each()
	gm.add_happiness(60)
	check(gm.happiness == 100, "Happiness capped at 100")
	gm.add_happiness(-200)
	check(gm.happiness == 0, "Happiness not below 0")

func test_hunger_clamp():
	_before_each()
	gm.add_hunger(70)
	check(gm.hunger == 100, "Hunger capped at 100")
	gm.add_hunger(-100)
	check(gm.hunger == 0, "Hunger not below 0")

func test_hygine_clamp():
	_before_each()
	gm.add_hygine(80)
	check(gm.hygine == 100, "Hygine capped at 100")
	gm.add_hygine(-150)
	check(gm.hygine == 0, "Hygine not below 0")

# -----------------------
# Queue Tests
# -----------------------
func test_add_to_queue():
	_before_each()
	gm.add_to_queue("Homuncu-feasting")
	check(gm.minigame_queue.size() == 1, "Add to queue size check")
	check(gm.minigame_queue[0] == "Homuncu-feasting", "Add to queue element check")

func test_remove_from_queue():
	_before_each()
	gm.add_to_queue("Homuncu-feasting")
	gm.add_to_queue("Guard")
	gm.remove_from_queue("Homuncu-feasting")
	check(gm.minigame_queue == ["Guard"], "Remove from queue check")
	check(gm.current_index == 0, "current_index reset after remove")

func test_report_minigame_finished():
	_before_each()
	gm.add_to_queue("Homuncu-feasting")
	gm.add_to_queue("Guard")
	check(gm.current_index == 0, "current_index before report")
	gm.report_minigame_finished()
	check(gm.current_index == 1, "current_index after report")

# -----------------------
# Edge Cases
# -----------------------
func test_start_queue_empty():
	_before_each()
	gm.start_queue()
	print("✅ start_queue_empty test ran (check Output for warnings)")

func test_play_next_invalid_scene():
	_before_each()
	gm.add_to_queue("Nonexistent")
	gm._play_next()
	print("✅ play_next_invalid_scene test ran (check Output for errors)")
