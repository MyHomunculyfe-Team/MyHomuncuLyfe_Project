extends Node2D

const PetStats = preload("res://scripts/PetStats.gd")

@onready var pet_name_label = $UI/PanelContainer/VBox/PetNameLabel
@onready var happiness_bar  = $UI/PanelContainer/VBox/Row_Happiness/HappinessBar
@onready var hunger_bar     = $UI/PanelContainer/VBox/Row_Hunger/HungerBar
@onready var hygiene_bar    = $UI/PanelContainer/VBox/Row_Hygiene/HygieneBar

var stats := PetStats.new()

# --- Demo rates (visible but not too fast) ---
const HUNGER_PER_SEC  := 0.20   # hunger moves toward 100 (more hungry) ~ +12/min
const HYGIENE_PER_SEC := -50  # hygiene decreases over time               ~ -9/min

func _ready() -> void:
	# Nice starting values for the demo (optional)
	stats.pet_name  = "Ramonculus"
	stats.happiness = 80
	stats.hunger    = 40
	stats.hygiene   = 60

	# Update UI whenever stats change
	stats.stats_changed.connect(update_ui)
	update_ui()

func update_ui() -> void:
	pet_name_label.text   = stats.pet_name
	happiness_bar.value   = stats.happiness
	hunger_bar.value      = stats.hunger
	hygiene_bar.value     = stats.hygiene

func _process(delta: float) -> void:
	# Slow, continuous change so the team can see it working
	stats.set_value("hunger",  stats.hunger  + HUNGER_PER_SEC  * delta)
	stats.set_value("hygiene", stats.hygiene + HYGIENE_PER_SEC * delta)
