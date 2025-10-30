extends Control

# ---------- Scene navigation ----------
@export_file("*.tscn") var home_scene := "res://scenes/main.tscn"

# ---------- Paths (set to match your scene tree) ----------
@export var path_prev:     NodePath = ^"MainPanel/CategoryBar/BtnPrev"
@export var path_next:     NodePath = ^"MainPanel/CategoryBar/BtnNext"
@export var path_care:     NodePath = ^"MainPanel/CategoryBar/BtnCare"
@export var path_food:     NodePath = ^"MainPanel/CategoryBar/BtnFood"
@export var path_clothes:  NodePath = ^"MainPanel/CategoryBar/BtnClothes"
@export var path_toys:     NodePath = ^"MainPanel/CategoryBar/BtnToys"
@export var grid_path:     NodePath = ^"MainPanel/ScrollItems/Padding/Grid"
@export var path_back:     NodePath = ^"MainPanel/BackButton"

# Money label (create a Label child under MoneyPill called "Amount")
@export var path_money:    NodePath = ^"TopBar/MoneyPill/Amount"

# Info panel (match your tree)
@export var path_desc_name:  NodePath = ^"MainPanel/ItemPanel/Name"
@export var path_desc_owned: NodePath = ^"MainPanel/ItemPanel/Owned"
@export var path_desc_text:  NodePath = ^"MainPanel/ItemPanel/Desc"
@export var path_use_btn:    NodePath = ^"MainPanel/ItemPanel/UseButton"

# Optional default icons per category
@export var care_icon: Texture2D
@export var food_icon: Texture2D
@export var clothes_icon: Texture2D
@export var toys_icon: Texture2D

# ---------- State ----------
var categories := ["care", "food", "clothes", "toys"]
var active_category := ""
var selected_item := ""

# ---------- Helpers ----------
func _btn(p: NodePath) -> BaseButton:
	if p == NodePath(""):
		return null
	var n := get_node_or_null(p)
	return n if n is BaseButton else null

@onready var btn_prev: BaseButton     = _btn(path_prev)
@onready var btn_next: BaseButton     = _btn(path_next)
@onready var btn_care: BaseButton     = _btn(path_care)
@onready var btn_food: BaseButton     = _btn(path_food)
@onready var btn_clothes: BaseButton  = _btn(path_clothes)
@onready var btn_toys: BaseButton     = _btn(path_toys)
@onready var btn_back: BaseButton     = _btn(path_back)
@onready var btn_use:  BaseButton     = _btn(path_use_btn)

@onready var money_label: Label   = get_node_or_null(path_money)      as Label
@onready var name_label:  Label   = get_node_or_null(path_desc_name)  as Label
@onready var owned_label: Label   = get_node_or_null(path_desc_owned) as Label
@onready var desc_label:  RichTextLabel = get_node_or_null(path_desc_text) as RichTextLabel

@onready var grid: Control = get_node_or_null(grid_path) as Control

var cat_group: ButtonGroup    # category buttons single-select
var slot_group: ButtonGroup   # grid item single-select

# Called automatically whenever inventory is updated (from GameState/Game autoload)
# cat = category where change happened, name = item name, new_count = updated value
func _on_inventory_changed(cat:String, name:String, new_count:int) -> void:
	# Refresh slots if this category is currently active
	if cat == active_category:
		_populate_grid()

	# Refresh right/bottom info panel if user has that item selected
	if selected_item != "" and name == selected_item:
		_update_info_panel()

func _ready() -> void:
	# arrows (optional)
	if btn_prev and not btn_prev.pressed.is_connected(_on_prev):
		btn_prev.pressed.connect(_on_prev)
	if btn_next and not btn_next.pressed.is_connected(_on_next):
		btn_next.pressed.connect(_on_next)

	# back & use
	if btn_back and not btn_back.pressed.is_connected(_on_back_pressed):
		btn_back.pressed.connect(_on_back_pressed)
	if btn_use:
		btn_use.disabled = true
		if not btn_use.pressed.is_connected(_on_use_pressed):
			btn_use.pressed.connect(_on_use_pressed)

	# category toggle group (single select, allow unpress)
	cat_group = ButtonGroup.new()
	cat_group.allow_unpress = true
	var cat_buttons: Array[BaseButton] = [btn_care, btn_food, btn_clothes, btn_toys]
	for i in cat_buttons.size():
		var b := cat_buttons[i]
		if not b:
			continue
		b.toggle_mode = true
		b.button_group = cat_group
		if not b.toggled.is_connected(_on_cat_toggled):
			b.toggled.connect(_on_cat_toggled.bind(i))

	# listen to global changes (autoload name is "Game")
	if not Game.money_changed.is_connected(_on_money_changed):
		Game.money_changed.connect(_on_money_changed)
	if not Game.inventory_changed.is_connected(_on_inventory_changed):
		Game.inventory_changed.connect(_on_inventory_changed)

	# initial paint
	_style_info_panel()
	_on_money_changed()
	_clear_selection()
	_clear_grid()


# ---------- Category navigation ----------
func _on_prev() -> void: _cycle_category(-1)
func _on_next() -> void: _cycle_category(+1)

func _cycle_category(step:int) -> void:
	var idx := categories.find(active_category)
	if idx == -1: idx = 0
	idx = int(posmod(idx + step, categories.size()))
	_set_category(idx)
	var btns: Array[BaseButton] = [btn_care, btn_food, btn_clothes, btn_toys]
	if idx < btns.size() and btns[idx]:
		btns[idx].button_pressed = true

func _on_cat_toggled(pressed:bool, index:int) -> void:
	if pressed:
		_set_category(index)
	else:
		if cat_group.get_pressed_button() == null:
			active_category = ""
			_clear_grid()
			_clear_selection()

func _set_category(i:int) -> void:
	i = clamp(i, 0, categories.size()-1)
	active_category = categories[i]
	selected_item = ""
	_populate_grid()
	_clear_selection()

# ---------- Grid helpers ----------
func _get_slots() -> Array:
	if grid == null: return []
	var out:Array = []
	for c in grid.get_children():
		# your ItemSlot nodes have set_item/clear and signal item_selected(name)
		if c.has_method("set_item") and c.has_signal("item_selected"):
			out.append(c)
	return out

func _icon_for(cat:String) -> Texture2D:
	match cat:
		"care":    return care_icon
		"food":    return food_icon
		"clothes": return clothes_icon
		"toys":    return toys_icon
		_:         return null

# ---------- POPULATE GRID (uses your ItemSlot signal) ----------
func _populate_grid() -> void:
	if grid == null:
		return

	var slots := _get_slots()
	var cat := active_category
	var names: Array = Game.CATALOG.get(cat, [])

	# single-select for item cards
	slot_group = ButtonGroup.new()
	slot_group.allow_unpress = true

	var call := Callable(self, "_on_slot_selected")

	for i in range(slots.size()):
		var s = slots[i]

		if s is Button:
			(s as Button).button_group = slot_group

		if i < names.size():
			var item_name: String = names[i]
			var count := Game.get_count(cat, item_name)

			var tex := Game.get_icon(cat, item_name)
			# optional fallback:
			# if tex == null: tex = _icon_for(cat)

			s.set_item(item_name, count, tex)

			# connect once (no extra bound args)
			if s.has_signal("item_selected"):
				if s.is_connected("item_selected", call):
					s.disconnect("item_selected", call)
				s.connect("item_selected", call)
		else:
			s.clear()


func _clear_grid() -> void:
	for s in _get_slots():
		s.clear()

# ---------- Selection / info panel ----------
func _on_slot_selected(name:String) -> void:
	print("[INV] selected:", active_category, "/", name)  # TEMP debug
	selected_item = name
	_update_info_panel()

func _update_info_panel() -> void:
	if active_category == "" or selected_item == "":
		_clear_selection()
		return

	var count := Game.get_count(active_category, selected_item)

	if name_label:
		name_label.text = selected_item
	if owned_label:
		owned_label.text = "%d Owned" % count
	if desc_label:
		desc_label.clear()
		desc_label.append_text(Game.get_description(active_category, selected_item))

	if btn_use:
		btn_use.disabled = (count <= 0)

func _clear_selection() -> void:
	selected_item = ""
	if name_label:  name_label.text = "Item name"
	if owned_label: owned_label.text = "0 Owned"
	if desc_label:
		desc_label.clear()
		desc_label.append_text("Select an item to see its description.")
	if btn_use:     btn_use.disabled = true


func _description_for(cat:String, name:String) -> String:
	return Game.get_description(cat, name)


# ---------- Use flow ----------
func _on_use_pressed() -> void:
	if active_category == "" or selected_item == "": return
	if Game.use_item(active_category, selected_item):
		_update_info_panel()
		_populate_grid() # refresh counts on cards

# ---------- Money ----------
func _on_money_changed() -> void:
	if money_label:
		money_label.text = str(Game.money)

# ---------- Navigation ----------
func _on_back_pressed() -> void:
	var err := get_tree().change_scene_to_file(home_scene)
	if err != OK:
		push_error("Failed to change scene to %s (err %d)" % [home_scene, err])

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE:
		_on_back_pressed()

func _style_info_panel() -> void:
	# Name (Label)
	if name_label:
		name_label.add_theme_color_override("font_color", Color(0,0,0,1))
		name_label.add_theme_color_override("font_outline_color", Color(1,1,1,1))
		name_label.add_theme_constant_override("outline_size", 2)

	# Owned (Label)
	if owned_label:
		owned_label.add_theme_color_override("font_color", Color(0,0,0,1))
		owned_label.add_theme_color_override("font_outline_color", Color(1,1,1,1))
		owned_label.add_theme_constant_override("outline_size", 2)
		owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Desc (RichTextLabel)
	if desc_label:
		# Make sure wrapping is on
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		# Force a visible color + outline
		desc_label.add_theme_color_override("default_color", Color(0,0,0,1))
		desc_label.add_theme_color_override("font_outline_color", Color(1,1,1,1))
		desc_label.add_theme_constant_override("outline_size", 2)
