extends Button

@export var overlay_color: Color = Color(1.0, 0.58, 0.0, 0.28)
@export var path_overlay:    NodePath = ^"SelectedOverlay"

# EXACT paths for your tree:
@export var path_icon:       NodePath = ^"Icon"                 # TextureRect
@export var path_badge_bg:   NodePath = ^"Badge/BadgeBG"        # TextureRect/ColorRect
@export var path_badge_cnt:  NodePath = ^"Badge/Count"          # Label
@export var path_name:       NodePath = ^"BottomBar/Item Name"  # <-- IMPORTANT

@onready var _icon: TextureRect  = get_node_or_null(path_icon)      as TextureRect
@onready var _badge_bg: CanvasItem = get_node_or_null(path_badge_bg) as CanvasItem
@onready var _badge_cnt: Label   = get_node_or_null(path_badge_cnt) as Label
@onready var _name: Label        = get_node_or_null(path_name)      as Label
@onready var _overlay: CanvasItem = get_node_or_null(path_overlay)  as CanvasItem

func _ready() -> void:
	toggle_mode = true
	for c in get_children():
		if c is Control: (c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _overlay == null:
		var cr := ColorRect.new()
		cr.name = "SelectedOverlay"
		cr.color = overlay_color
		cr.visible = false
		cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cr.anchor_left = 0; cr.anchor_top = 0; cr.anchor_right = 1; cr.anchor_bottom = 1
		add_child(cr); _overlay = cr
	toggled.connect(func(is_pressed: bool) -> void:
		if _overlay: _overlay.visible = is_pressed
	)
	clear()

func set_item(item_name: String, count: int = 0, item_icon: Texture2D = null) -> void:
	if _name:  _name.text = item_name
	if _icon:
		_icon.texture = item_icon
		_icon.visible = item_icon != null
	if _badge_bg:  _badge_bg.visible = true
	if _badge_cnt:
		_badge_cnt.visible = count > 0
		_badge_cnt.text = str(count)

func clear() -> void:
	set_item("Item Name", 0, null)
	if _overlay: _overlay.visible = false
	button_pressed = false
