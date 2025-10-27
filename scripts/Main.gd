extends Node2D

const PetStats = preload("res://scripts/PetStats.gd")

@onready var pet_name_label = $UI/PanelContainer/VBox/PetNameLabel
@onready var pet_name_edit  = $UI/PanelContainer/VBox/PetNameEdit
@onready var happiness_bar  = $UI/PanelContainer/VBox/Row_Happiness/HappinessBar
@onready var hunger_bar     = $UI/PanelContainer/VBox/Row_Hunger/HungerBar
@onready var hygiene_bar    = $UI/PanelContainer/VBox/Row_Hygiene/HygieneBar

@onready var deformity_popup = $DeformityPopup
@onready var deformity_label = $DeformityPopup/DeformityLabel

var stats := PetStats.new()

# --- Demo rates (visible but not too fast) ---
const HUNGER_PER_SEC  := 0.20   # hunger moves toward 100 (more hungry)
const HYGIENE_PER_SEC := -50    # hygiene decreases over time


func _ready() -> void:
	# Nice starting values for the demo (optional)
	stats.pet_name  = "Ramonculus"
	stats.happiness = 80
	stats.hunger    = 40
	stats.hygiene   = 60
	stats.deformity_warning.connect(_on_deformity_warning)

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


func _on_deformity_warning(stat_name: String) -> void:
	if deformity_popup and deformity_label:
		deformity_label.text = "⚠️ Warning: %s stat is critically high (≥10)!" % stat_name
		deformity_popup.show()

		await get_tree().create_timer(3.0).timeout
		deformity_popup.hide()
	else:
		print("⚠️ Deformity popup not found in scene.")

# ===============================
#  PET NAME CHANGE
# ===============================
func _on_pet_name_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.doubleclick and event.button_index == MOUSE_BUTTON_LEFT:
		pet_name_edit.text = pet_name_label.text
		pet_name_label.visible = false
		pet_name_edit.visible = true
		pet_name_edit.grab_focus()


func _on_pet_name_edit_text_submitted(new_text: String) -> void:
	stats.pet_name = new_text.strip_edges()
	pet_name_label.text = stats.pet_name
	pet_name_label.visible = true
	pet_name_edit.visible = false
