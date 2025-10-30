
extends Button

@export var path_icon:      NodePath
@export var path_badge_bg:  NodePath
@export var path_badge_cnt: NodePath

@onready var _icon: TextureRect    = get_node(path_icon)
@onready var _badge_bg: CanvasItem = get_node(path_badge_bg)
@onready var _badge_cnt: Label     = get_node(path_badge_cnt)

var _name := ""
var _count := 0

func _ready() -> void:
	toggle_mode = false              # not tabs
	text = ""                        # we show an icon, not text
	_clear_children_mouse()
	clear()

func set_item(nm: String, cnt: int, tex: Texture2D) -> void:
	_name = nm
	_count = cnt

	if _icon:
		_icon.texture = tex
		_icon.visible = tex != null

	# Always show badge background and count
	if _badge_bg:
		_badge_bg.visible = true
	if _badge_cnt:
		_badge_cnt.text = str(cnt)
		_badge_cnt.visible = true

	disabled = false



func clear() -> void:
	_name = ""
	_count = 0
	if _icon:
		_icon.texture = null
		_icon.visible = false
	if _badge_bg:  _badge_bg.visible = false
	if _badge_cnt:
		_badge_cnt.text = ""
		_badge_cnt.visible = false
	disabled = true

func _clear_children_mouse() -> void:
	for c in get_children():
		if c is Control:
			(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
