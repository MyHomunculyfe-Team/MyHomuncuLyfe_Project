extends Control
class_name InventoryPopup

# ---- Drag these in the Inspector ----
@export_node_path("ColorRect")      var dimmer_path: NodePath
@export_node_path("Button")         var care_btn_path: NodePath
@export_node_path("Button")         var food_btn_path: NodePath
@export_node_path("GridContainer")  var grid_path: NodePath
@export_node_path("Button")         var close_btn_path: NodePath

@onready var _dimmer: ColorRect     = get_node_or_null(dimmer_path)
@onready var _btn_care: Button      = get_node_or_null(care_btn_path)
@onready var _btn_food: Button      = get_node_or_null(food_btn_path)
@onready var _grid: GridContainer   = get_node_or_null(grid_path)
@onready var _btn_close: Button     = get_node_or_null(close_btn_path)

# --- Tiny demo catalog + icons  ---
const CATALOG := {
	"care": ["Comb", "Shampoo", "Bath Soap", "Towel", "Lotion", "Toothbrush", "Toothpaste", "Face Wash"],
	"food": ["Fish", "Biscuits", "Cake", "Fruit", "Bone", "Chicken", "Kibble", "Veggies"],
}
const ICONS := {
	"care": {
		"Comb":      "res://assets/icons/inventory/comb.png",
		"Shampoo":   "res://assets/icons/inventory/shampoo.png",
		"Bath Soap": "res://assets/icons/inventory/soap.png",
		"Towel":     "res://assets/icons/inventory/towel.png",
		"Lotion":      "res://assets/icons/inventory/lotion.png",
		"Toothbrush":   "res://assets/icons/inventory/toothbrush.png",
		"Toothpaste": "res://assets/icons/inventory/toothpaste.png",
		"Face Wash":     "res://assets/icons/inventory/face_wash.png",
		
	},
	"food": {
		"Fish":     "res://assets/icons/inventory/fish.png",
		"Biscuits": "res://assets/icons/inventory/biscuits.png",
		"Cake":     "res://assets/icons/inventory/cake.png",
		"Fruit":    "res://assets/icons/inventory/fruit.png",
		"Bone":     "res://assets/icons/inventory/bone.png",
		"Chicken": "res://assets/icons/inventory/chicken.png",
		"Kibble":     "res://assets/icons/inventory/kibble.png",
		"Veggies":    "res://assets/icons/inventory/veggies.png",
		
	},
}

var _active_cat: String = "care"
var _cost: Dictionary = {}   # optional { "care": {"Comb":true}, "food": {...} }

# ----------------------------------------------------------------
# lifecycle
# ----------------------------------------------------------------
func _ready() -> void:
	# hidden by default
	hide()
	if _dimmer:
		_dimmer.visible = false
		_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# wire buttons
	if _btn_care and not _btn_care.pressed.is_connected(_on_care_pressed):
		_btn_care.pressed.connect(_on_care_pressed)
	if _btn_food and not _btn_food.pressed.is_connected(_on_food_pressed):
		_btn_food.pressed.connect(_on_food_pressed)
	if _btn_close and not _btn_close.pressed.is_connected(_on_close_pressed):
		_btn_close.pressed.connect(_on_close_pressed)

	_update_tabs()

# called by CareSelector when user clicks “Inventory”
func open_with_cost(cost: Dictionary) -> void:
	_cost = cost
	_show_popup(true)
	_populate()

# ----------------------------------------------------------------
# UI events
# ----------------------------------------------------------------
func _on_close_pressed() -> void:
	_show_popup(false)

func _on_care_pressed() -> void:
	if _active_cat == "care":
		return
	_active_cat = "care"
	_update_tabs()
	_populate()

func _on_food_pressed() -> void:
	if _active_cat == "food":
		return
	_active_cat = "food"
	_update_tabs()
	_populate()

func _update_tabs() -> void:
	if _btn_care:
		_btn_care.button_pressed = (_active_cat == "care")
	if _btn_food:
		_btn_food.button_pressed = (_active_cat == "food")

func _show_popup(visible_now: bool) -> void:
	visible = visible_now
	if _dimmer:
		_dimmer.visible = visible_now
		if visible_now:
			_dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE

# ----------------------------------------------------------------
# data → slots
# ----------------------------------------------------------------
func _populate() -> void:
	if _grid == null:
		return

	# collect slot nodes 
	var slots: Array[Node] = []
	for c in _grid.get_children():
		if c is Button:
			slots.append(c)

	# paint slots for active category
	var names: Array = CATALOG.get(_active_cat, [])
	var idx := 0
	for s in slots:
		if idx < names.size():
			var nm: String = names[idx]
			var tex: Texture2D = _get_icon(_active_cat, nm)
			var cnt: int = _get_count(_active_cat, nm)
			_set_slot(s, nm, cnt, tex)
		else:
			_clear_slot(s)
		idx += 1

	# fade non-required slots if a cost map was provided
	if _cost.has(_active_cat) and typeof(_cost[_active_cat]) == TYPE_DICTIONARY:
		var need_map: Dictionary = _cost[_active_cat]
		var j := 0
		for s in slots:
			if j >= names.size():
				break
			var nm2: String = names[j]
			var needed := need_map.has(nm2)
			if s is CanvasItem:
				if needed:
					(s as CanvasItem).modulate = Color(1, 1, 1, 1)
				else:
					(s as CanvasItem).modulate = Color(1, 1, 1, 0.7)
			j += 1

# Works with PopupItemSlot.gd OR a plain Button with `icon` + `count` children
func _set_slot(slot: Node, item_name: String, count: int, tex: Texture2D) -> void:
	if slot.has_method("set_item"):
		# use PopupItemSlot.gd
		slot.call("set_item", item_name, count, tex)
	else:
		if slot is Button:
			var t := slot.get_node_or_null(^"icon") as TextureRect
			var l := slot.get_node_or_null(^"count") as Label
			if t:
				t.texture = tex
				t.visible = true  # always show icon background
			if l:
				l.text = str(count)  # show even 0
				l.visible = true     # make label visible even if 0
			slot.disabled = false
			slot.visible = true
			slot.hint_tooltip = item_name


func _clear_slot(slot: Node) -> void:
	if slot.has_method("clear"):
		slot.call("clear")
	else:
		if slot is Button:
			var t := slot.get_node_or_null(^"icon") as TextureRect
			var l := slot.get_node_or_null(^"count") as Label
			if t:
				t.texture = null
				t.visible = false
			if l:
				l.text = ""
				l.visible = false
			slot.disabled = true
			slot.hint_tooltip = ""

# ----------------------------------------------------------------
# helpers
# ----------------------------------------------------------------
func _get_icon(cat: String, nm: String) -> Texture2D:
	var p: String = (ICONS.get(cat, {}) as Dictionary).get(nm, "")
	if p != "":
		return load(p) as Texture2D
	return null

func _get_count(cat: String, nm: String) -> int:
	# TODO:
	return int(hash(cat + nm) % 3)
