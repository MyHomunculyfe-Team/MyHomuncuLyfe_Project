extends Area2D

@export var bonding: int = 0
@export var cooldown_time: float = 0.5

var _is_mouse_over := false
var _last_mouse_pos: Vector2
var _last_direction: Vector2 = Vector2.ZERO
var _can_increase := true
var _cooldown_timer: float = 0.0


func _ready():
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))


func _on_mouse_entered():
	_is_mouse_over = true

func _on_mouse_exited():
	_is_mouse_over = false


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


func increase_bonding():
	bonding += 1
	print("Bonding increased! Current bonding =", bonding)
