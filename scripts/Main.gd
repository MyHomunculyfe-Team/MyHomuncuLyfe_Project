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
@onready var lbl_name: Label       = get_node_or_null(P_NAME_LABEL)
@onready var bar_happiness: Range  = get_node_or_null(P_BAR_HAPPINESS)
@onready var bar_hunger: Range     = get_node_or_null(P_BAR_HUNGER)
@onready var bar_hygiene: Range    = get_node_or_null(P_BAR_HYGIENE)

@onready var btn_items: BaseButton = get_node_or_null(P_BTN_ITEMS)
@onready var bg_gradient: Control  = get_node_or_null(P_BG_GRADIENT)
@onready var bg_pattern: Control   = get_node_or_null(P_BG_PATTERN)
@onready var buttons_wrap: Control = get_node_or_null(P_BUTTONS_WRAP)

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
		

func _process(delta):
	_refresh_stats()


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
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		var mp := get_viewport().get_mouse_position()
		var top: Control = get_viewport().gui_pick(mp)
		if top:
			print("[PICK] at ", mp, " -> ", top.name, " path=", top.get_path())
		else:
			print("[PICK] at ", mp, " -> no Control")

# Update UI from Game (safe-guards)
func _refresh_stats() -> void:
	if lbl_name:      lbl_name.text = GameManager.pet_name
	if bar_happiness: bar_happiness.value = int(GameManager.happiness)
	if bar_hunger:    bar_hunger.value    = int(GameManager.hunger)
	if bar_hygiene:   bar_hygiene.value   = int(GameManager.hygine)

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
