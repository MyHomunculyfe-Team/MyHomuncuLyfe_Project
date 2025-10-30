# Main.gd (Godot 4)
extends Node2D

# -------- Scene path (set this to Inventory scene) --------
@export_file("*.tscn") var inventory_scene := "res://scenes/inventory.tscn"

# -------- Node paths (match tree) --------
const P_STATS_PANEL   := ^"UI/Inner Boarder"
const P_NAME_LABEL    := ^"UI/Inner Boarder/VBoxMain/PetNameBox/PetNameLabel"
const P_BAR_HAPPINESS := ^"UI/Inner Boarder/VBoxMain/VBoxStats/Row_Happiness/HappinessBar"
const P_BAR_HUNGER    := ^"UI/Inner Boarder/VBoxMain/VBoxStats/Row_Hunger/HungerBar"
const P_BAR_HYGIENE   := ^"UI/Inner Boarder/VBoxMain/VBoxStats/Row_Hygiene/HygieneBar"

const P_BTN_ITEMS     := ^"UI/NavPanel/Buttons/Btn_Items"
const P_BG_GRADIENT   := ^"UI/NavPanel/BG_Gradient"
const P_BG_PATTERN    := ^"UI/NavPanel/BG_Pattern"
const P_BUTTONS_WRAP  := ^"UI/NavPanel/Buttons"

# -------- Cached nodes --------
@onready var stats_panel: Control  = get_node_or_null(P_STATS_PANEL)
@onready var pet_name_label: Label = get_node_or_null(P_NAME_LABEL)
@onready var bar_happiness: Range  = get_node_or_null(P_BAR_HAPPINESS)
@onready var bar_hunger: Range     = get_node_or_null(P_BAR_HUNGER)
@onready var bar_hygiene: Range    = get_node_or_null(P_BAR_HYGIENE)

@onready var btn_items: BaseButton = get_node_or_null(P_BTN_ITEMS)
@onready var bg_gradient: Control  = get_node_or_null(P_BG_GRADIENT)
@onready var bg_pattern: Control   = get_node_or_null(P_BG_PATTERN)
@onready var buttons_wrap: Control = get_node_or_null(P_BUTTONS_WRAP)

@onready var pet_name_edit  = $"UI/Inner Boarder/VBoxMain/PetNameEdit"
@onready var deformity_popup: AcceptDialog = $UI/DeformityPopup
@onready var deformity_label: Label = $UI/DeformityPopup/DeformityLabel

func _ready() -> void:
	print("[Main] _ready()")
	# Show stats now 
	if stats_panel:
		stats_panel.visible = true
	# Backgrounds must not eat mouse
	if bg_gradient: bg_gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bg_pattern:  bg_pattern.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	if buttons_wrap: buttons_wrap.mouse_filter = Control.MOUSE_FILTER_PASS
	# Ensure Items button is clickable + connected
	if btn_items:
		_ensure_clickable_button(btn_items)
		if not btn_items.pressed.is_connected(_on_btn_items_pressed):
			btn_items.pressed.connect(_on_btn_items_pressed)
		if not btn_items.gui_input.is_connected(_dbg_items_gui_input):
			btn_items.gui_input.connect(_dbg_items_gui_input)
	else:
		push_error("[Main] Btn_Items NOT found at: %s" % P_BTN_ITEMS)
		
	GameManager.deformity_warning.connect(_on_deformity_warning)
	GameManager.stats_changed.connect(_on_stats_changed)
	
	_refresh_stats()

func _on_timer_timeout() -> void:
	GameManager.add_value("hunger", -0.1)
	GameManager.add_value("happiness", -0.1)
	GameManager.add_value("hygiene", -0.1)

func _on_stats_changed() -> void:
	# Whenever stats change, refresh UI
	_refresh_stats()
	
func _on_deformity_warning(stat_name: String) -> void:
	# Show popup when GameManager says so
	warn_deformity(stat_name)

func _ensure_clickable_button(b: BaseButton) -> void:
	b.z_index = 100
	if b.custom_minimum_size.x < 80.0 or b.custom_minimum_size.y < 80.0:
		b.custom_minimum_size = Vector2(120, 120) # give it a clear hit-box
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	for c in b.get_children():
		if c is Control:
			(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("[Btn_Items] size=", b.size, " global_rect=", b.get_global_rect())

# Debug: see any GUI events that reach the button
func _dbg_items_gui_input(e: InputEvent) -> void:
	print("[Btn_Items] gui_input: ", e)

# Click anywhere: tell me which Control is on top at mouse
func _unhandled_input(e: InputEvent) -> void:
	pass

# Update UI from Game (safe-guards)
func _refresh_stats() -> void:
	if pet_name_label: pet_name_label.text = GameManager.pet_name
	if bar_happiness: bar_happiness.value = int(GameManager.happiness)
	if bar_hunger:    bar_hunger.value    = int(GameManager.hunger)
	if bar_hygiene:   bar_hygiene.value   = int(GameManager.hygiene)

# Editor-connected or fallback-connected handler
func _on_btn_items_pressed() -> void:
	print("[UI] Items clicked → ", inventory_scene)
	var err := get_tree().change_scene_to_file(inventory_scene)
	if err != OK:
		push_error("Failed to change scene to %s (err %d)" % [inventory_scene, err])

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_btn_care_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/careselector.tscn")


func _on_btn_job_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/jobselector.tscn")
	

func warn_deformity(stat_name: String) -> void:
	if deformity_popup and deformity_label:
		deformity_label.text = "⚠️ Warning: %s stat is critically low!" % stat_name
		deformity_popup.show()

		await get_tree().create_timer(3.0).timeout
		deformity_popup.hide()
	else:
		print("⚠️ Deformity popup not found in scene.")
		

#===============================
#  PET NAME CHANGE
# ===============================
func _on_pet_name_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.doubleclick and event.button_index == MOUSE_BUTTON_LEFT:
		pet_name_edit.text = pet_name_label.text
		pet_name_label.visible = false
		pet_name_edit.visible = true
		pet_name_edit.grab_focus()


func _on_pet_name_edit_text_submitted(new_text: String) -> void:
	GameManager.pet_name = new_text.strip_edges()
	pet_name_label.text = GameManager.pet_name
	pet_name_label.visible = true
	pet_name_edit.visible = false
	
func _on_ok_button_pressed() -> void:
	deformity_popup.hide()
