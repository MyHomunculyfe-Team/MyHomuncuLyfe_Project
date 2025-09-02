# res://scripts/Pet.gd
extends Sprite2D

# --- Layout / safe-area controls (tune these to match your UI) ---
@export var left_margin: float = 120.0   # width of the left nav panel
@export var top_margin:  float = 200.0   # height of the top stats panel
@export var pad:         float = 20.0    # extra padding inside the safe area
@export var show_debug_rect: bool = false

# --- Movement controls ---
@export var speed_px_per_sec: float = 140.0         # walk speed
@export var pause_range:      Vector2 = Vector2(1.0, 3.0)  # random pause (sec)

# Computed wander region (auto-updated)
var move_rect: Rect2 = Rect2(Vector2(120, 200), Vector2(500, 200))

# RNG
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_update_move_rect()                                   # compute initial safe area
	get_viewport().size_changed.connect(_update_move_rect) # recompute on resize
	_start_idle_bob()
	_wander_around()

# Recompute the rectangle the pet is allowed to wander in, 
# avoiding the left nav + top stats and keeping a padding.
func _update_move_rect() -> void:
	var vp_size: Vector2 = get_viewport_rect().size

	var x: float = left_margin + pad
	var y: float = top_margin  + pad
	var w: float = max(1.0, (vp_size.x - x) - pad)
	var h: float = max(1.0, (vp_size.y - y) - pad)

	move_rect = Rect2(Vector2(x, y), Vector2(w, h))
	queue_redraw()  # refresh debug draw if enabled

# Coroutine: wander forever to random points inside move_rect
func _wander_around() -> void:
	await get_tree().process_frame  # let scene settle
	while true:
		var target: Vector2 = _random_point_in_rect(move_rect)
		var dist:   float   = (target - global_position).length()
		var duration: float = max(0.15, dist / speed_px_per_sec)

		var tw := create_tween()
		tw.tween_property(self, "global_position", target, duration)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tw.finished

		var wait_time: float = rng.randf_range(pause_range.x, pause_range.y)
		await get_tree().create_timer(wait_time).timeout

# Gentle idle bob loop
func _start_idle_bob() -> void:
	var bob := create_tween().set_loops()
	var up: float = 6.0
	var t:  float = 0.8
	bob.tween_property(self, "position:y", position.y - up, t)\
	   .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	bob.tween_property(self, "position:y", position.y, t)\
	   .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

# Utils
func _random_point_in_rect(r: Rect2) -> Vector2:
	var rx: float = rng.randf_range(r.position.x, r.position.x + r.size.x)
	var ry: float = rng.randf_range(r.position.y, r.position.y + r.size.y)
	return Vector2(rx, ry)

# Optional: draw the safe area for debugging 
func _draw() -> void:
	if show_debug_rect:
		draw_rect(move_rect, Color(0, 1, 0, 0.12), true)
		draw_rect(move_rect, Color(0, 1, 0, 0.8), 2.0)
