# Pet.gd (Godot 4)
extends Node2D

@export var speed_px_per_sec: float = 140.0
@export var pause_range: Vector2 = Vector2(0.6, 1.6)
@export var left_margin: float = 120.0
@export var top_margin: float = 120.0
@export var pad: float = 24.0
@export var bob_amplitude: float = 2.0
@export var bob_speed: float = 2.6
@export var start_delay: float = 5.0   # <- wait this long before first movement

var animated_sprite: AnimatedSprite2D
var _target: Vector2
var _waiting := false
var _bob_t := 0.0

func _ready() -> void:
	randomize()
	animated_sprite = $Pet
	animated_sprite.play("Walk")  # your one-frame anim
	# initial delay before the first wander
	_waiting = true
	await get_tree().create_timer(max(0.0, start_delay)).timeout
	_waiting = false
	_pick_new_target()

func _process(delta: float) -> void:
	# subtle idle bobbing even while waiting
	_bob_t += delta

	if _waiting:
		return

	var to_vec := _target - global_position
	var dist := to_vec.length()

	if dist < 2.0:
		_wait_then_move_again()
		return

	var step := to_vec.normalized() * speed_px_per_sec * delta
	if step.length() > dist:
		step = to_vec
	global_position += step


func _pick_new_target() -> void:
	var viewport_size := get_viewport_rect().size
	var x := randf_range(left_margin + pad, viewport_size.x - pad)
	var y := randf_range(top_margin + pad, viewport_size.y - pad)
	_target = Vector2(x, y)

func _wait_then_move_again() -> void:
	_waiting = true
	var t := randf_range(pause_range.x, pause_range.y)
	await get_tree().create_timer(t).timeout
	_waiting = false
	_pick_new_target()
	
