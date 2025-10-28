extends Control

# ---- Drag these in the Inspector after saving ----
@export var path_prev: NodePath
@export var path_next: NodePath
@export var path_care: NodePath
@export var path_food: NodePath
@export var path_clothes: NodePath
@export var path_toys: NodePath
@export var grid_path: NodePath          # e.g. MainPanel/ScrollItems/Padding/Grid
@export var care_icon: Texture2D         # drag your comb icon here

var categories := ["care", "food", "clothes", "toys"]
var active_category := ""                 # start with NONE selected

# Sprint-1 demo data for CARE
var care_items := [
	{"name": "Comb"},
	{"name": "Shampoo"},
	{"name": "Bath Soap"},
	{"name": "Towel"},
]

func _btn(p: NodePath) -> BaseButton:
	if p == NodePath(""): return null
	var n := get_node_or_null(p)
	return n if n is BaseButton else null

@onready var btn_prev: BaseButton    = _btn(path_prev)
@onready var btn_next: BaseButton    = _btn(path_next)
@onready var btn_care: BaseButton    = _btn(path_care)
@onready var btn_food: BaseButton    = _btn(path_food)
@onready var btn_clothes: BaseButton = _btn(path_clothes)
@onready var btn_toys: BaseButton    = _btn(path_toys)
@onready var grid: Control           = get_node_or_null(grid_path) as Control
@onready var cat_buttons: Array[BaseButton] = [btn_care, btn_food, btn_clothes, btn_toys]

var cat_group: ButtonGroup

func _ready() -> void:
	# (optional) arrows
	if btn_prev and not btn_prev.pressed.is_connected(_on_prev):
		btn_prev.pressed.connect(_on_prev)
	if btn_next and not btn_next.pressed.is_connected(_on_next):
		btn_next.pressed.connect(_on_next)

	# Single-select categories; allow unselect
	cat_group = ButtonGroup.new()
	cat_group.allow_unpress = true
	for i in cat_buttons.size():
		var b := cat_buttons[i]
		if not b: continue
		b.toggle_mode = true
		b.button_group = cat_group
		if not b.toggled.is_connected(_on_cat_toggled):
			b.toggled.connect(_on_cat_toggled.bind(i))

	# Start UNSELECTED (no button pressed, placeholders only)
	_clear_grid()

func _on_prev() -> void:
	# if you want prev/next to cycle categories you can implement later
	pass

func _on_next() -> void:
	pass

func _on_cat_toggled(is_pressed: bool, index: int) -> void:
	if is_pressed:
		_select_category(index)
	else:
		# If nothing is pressed after unpress → clear to placeholders
		if cat_group.get_pressed_button() == null:
			active_category = ""
			_clear_grid()

func _select_category(i: int) -> void:
	i = clamp(i, 0, categories.size() - 1)
	active_category = categories[i]
	_populate_grid()

func _get_slots() -> Array:
	if grid == null: return []
	var out: Array = []
	for c in grid.get_children():
		if c.has_method("set_item"):
			out.append(c)
	return out

func _populate_grid() -> void:
	if grid == null:
		push_warning("Inventory: grid_path not set on Inventory node.")
		return

	var show_care := (active_category == "care")
	var icon_to_use: Texture2D = care_icon if show_care else null

	var slots := _get_slots()
	var idx := 0
	for s in slots:
		if show_care and idx < care_items.size():
			var it = care_items[idx]
			s.set_item(it.get("name", "Item Name"), 0, icon_to_use)  # count=0 for now
		else:
			s.clear()  # -> label "Item Name", icon cleared, money pill stays
		idx += 1

func _clear_grid() -> void:
	for s in _get_slots():
		s.clear()
