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

@export var bonding: int = 0
@export var cooldown_time: float = 0.5

var animated_sprite: AnimatedSprite2D
var _target: Vector2
var _waiting := false
var _bob_t := 0.0

#Petting
var _is_mouse_over := false
var _last_mouse_pos: Vector2
var _last_direction: Vector2 = Vector2.ZERO
var _can_increase := true
var _cooldown_timer: float = 0.0

func _ready() -> void:
	randomize()
	animated_sprite = $AnimatedSprite2D
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
	
func _input_event(viewport, event, shape_idx):
	# Start tracking when you click inside the area
	if event is InputEventMouseButton and event.pressed and _is_mouse_over:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_last_mouse_pos = event.position
			_last_direction = Vector2.ZERO
			_can_increase = true
			_cooldown_timer = 0.0
			
func _input(event):
	if not _is_mouse_over:
		return

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var current_pos = event.position
		var movement = current_pos - _last_mouse_pos

		if movement.length() > 5.0:
			var direction = movement.normalized()
			if _last_direction != Vector2.ZERO and direction.dot(_last_direction) < 0.0:
				if _can_increase:
					increase_bonding()
					_can_increase = false
					_cooldown_timer = cooldown_time

			_last_direction = direction
			_last_mouse_pos = current_pos

	if not _can_increase:
		_cooldown_timer -= get_process_delta_time()
		if _cooldown_timer <= 0.0:
			_can_increase = true


func _on_mouse_entered():
	_is_mouse_over = true

func _on_mouse_exited():
	_is_mouse_over = false

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
	
func increase_bonding():
	GameManager.add_value("happiness", 20)
	squish()
	
func squish():
	var tween = create_tween()

	tween.tween_property(animated_sprite, "scale", animated_sprite.scale * Vector2(1.2, 0.9), 0.1)
	tween.tween_property(animated_sprite, "scale", animated_sprite.scale, 0.1)
	
