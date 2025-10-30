extends Control

@export var dimmer_path: NodePath        = ^"Dimmer"
@export var panel_bg_path: NodePath      = ^"PopupPanelBG"
@export var grid_path: NodePath          = ^"GridContainer"

@export var care_btn_path: NodePath      = ^"CareButton"
@export var food_btn_path: NodePath      = ^"FoodButton"

# If left empty, we’ll create lightweight slots in code (no dependency on ItemSlot.tscn)
@export var slot_scene: PackedScene
@export var slot_count: int = 8
@export var grid_columns: int = 4

var _current_category: String = "care"
var _cost: Dictionary = {}
var _slots: Array[Node] = []

@onready var _dimmer: ColorRect     = get_node_or_null(dimmer_path)       as ColorRect
@onready var _panel_bg: CanvasItem  = get_node_or_null(panel_bg_path)     as CanvasItem
@onready var _grid: GridContainer   = get_node_or_null(grid_path)         as GridContainer
@onready var _btn_care: BaseButton  = get_node_or_null(care_btn_path)     as BaseButton
@onready var _btn_food: BaseButton  = get_node_or_null(food_btn_path)     as BaseButton

signal closed

func _ready() -> void:
	if _grid: _grid.columns = max(1, grid_columns)
	_build_slots_if_needed()

	if _dimmer and not _dimmer.gui_input.is_connected(_on_dimmer_input):
		_dimmer.gui_input.connect(_on_dimmer_input)

	if _btn_care and not _btn_care.pressed.is_connected(func(): _switch_category("care")):
		_btn_care.pressed.connect(func(): _switch_category("care"))
	if _btn_food and not _btn_food.pressed.is_connected(func(): _switch_category("food")):
		_btn_food.pressed.connect(func(): _switch_category("food"))

	if typeof(Game) != TYPE_NIL and Game.has_signal("inventory_changed"):
		if not Game.inventory_changed.is_connected(_on_inventory_changed):
			Game.inventory_changed.connect(_on_inventory_changed)

	hide()

# ---------- Public API ----------
func open_with_cost(cost: Dictionary, category: String = "care") -> void:
	_cost = cost if typeof(cost) == TYPE_DICTIONARY else {}
	_current_category = (category if category in ["care","food"] else "care")
	_refresh()
	show()

func open_simple(category: String = "care") -> void:
	open_with_cost({}, category)

func close() -> void:
	hide()
	emit_signal("closed")

# ---------- Internals ----------
func _on_dimmer_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed:
		close()

func _on_inventory_changed(_c:String, _n:String, _v:int) -> void:
	if visible:
		_refresh()

func _switch_category(cat:String) -> void:
	if cat == _current_category: return
	_current_category = cat
	_refresh()

func _get_icon(cat:String, name:String) -> Texture2D:
	if typeof(Game) != TYPE_NIL and Game.has_method("get_icon"):
		return Game.get_icon(cat, name)
	return null

func _build_slots_if_needed() -> void:
	if not _grid or _slots.size() > 0:
		return

	_slots.clear()

	if slot_scene != null:
		# Use your real ItemSlot.tscn
		for i in range(slot_count):
			var inst := slot_scene.instantiate()
			_grid.add_child(inst)
			_slots.append(inst)
	else:
		# Lightweight slot implemented here so no merge is needed
		for i in range(slot_count):
			var slot := _make_light_slot()
			_grid.add_child(slot)
			_slots.append(slot)

# --- lightweight slot (no external scene) ---
func _make_light_slot() -> Control:
	var root := Button.new()
	root.custom_minimum_size = Vector2(160, 160)
	root.focus_mode = Control.FOCUS_NONE

	var vb := VBoxContainer.new()
	vb.anchor_right = 1; vb.anchor_bottom = 1
	vb.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vb.grow_vertical = Control.GROW_DIRECTION_BOTH
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(vb)

	var icon := TextureRect.new()
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(96, 96)
	icon.name = "Icon"
	vb.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.name = "Name"
	vb.add_child(name_lbl)

	var badge := Label.new()
	badge.name = "Count"
	badge.text = "0"
	badge.add_theme_color_override("font_color", Color(1,1,1))
	badge.add_theme_font_size_override("font_size", 22)
	badge.position = Vector2(8, 8)
	badge.z_index = 5
	root.add_child(badge)

	# add API compatible with ItemSlot:
	root.set_meta("icon", icon)
	root.set_meta("name_lbl", name_lbl)
	root.set_meta("count_lbl", badge)

	root.set("set_item", func(item_name:String, count:int, tex:Texture2D) -> void:
		(root.get_meta("name_lbl") as Label).text = item_name
		(root.get_meta("count_lbl") as Label).text = str(count)
		var tr := root.get_meta("icon") as TextureRect
		tr.texture = tex
		tr.visible = tex != null
	)

	root.set("clear", func() -> void:
		(root.get_meta("name_lbl") as Label).text = "Item"
		(root.get_meta("count_lbl") as Label).text = ""
		(root.get_meta("icon") as TextureRect).texture = null
	)

	return root

func _refresh() -> void:
	if not _grid: return

	var names: Array = []
	if typeof(Game) != TYPE_NIL and Game.has("CATALOG"):
		names = Game.CATALOG.get(_current_category, [])

	var idx := 0
	for slot in _slots:
		if idx < names.size():
			var nm:String = names[idx]
			var cnt:int = (Game.get_count(_current_category, nm) if typeof(Game) != TYPE_NIL else 0)
			var tex := _get_icon(_current_category, nm)

			if slot.has_method("set_item"):
				slot.set_item(nm, cnt, tex)

			var needed := false
			if _cost.has(_current_category) and typeof(_cost[_current_category]) == TYPE_DICTIONARY:
				needed = _cost[_current_category].has(nm)

			if needed:
				slot.modulate = Color(1,1,1,1)
			else:
				slot.modulate = Color(1,1,1,0.65)
		else:
			if slot.has_method("clear"):
				slot.clear()

		idx += 1
