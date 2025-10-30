extends CharacterBody2D

@export var speed: float = 200.0
@export var appear_time: float = 5.0   
@export var disappear_time: float = 3.0  
@export var food_float_area: Area2D

var dragging := false
var drag_offset := Vector2.ZERO
var moving_dir := Vector2(1, 1).normalized()

var is_visible_mode := false
var timer := 0.0
var bounce_velocity
var is_on_bowl = false
var cycle = false

var _sprite : Sprite2D  
var _tween: Tween

func _ready():
	food_float_area = $"../FoodFloatArea"
	_sprite = $Sprite2D
	
	randomize() # pick a random diagonal direction 
	var angle = randf_range(0.0, TAU) 
	bounce_velocity = Vector2(cos(angle), sin(angle)) * speed
	
	input_pickable = false
	_sprite.visible = false
	cycle = true  # start automatic loop
	_cycle_mode()

func _input_event(_viewport, event, _shape_idx):
	if not is_visible_mode:
		return  # ignore clicks when invisible
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
		else:
			dragging = false

func _unhandled_input(event):
	if not is_visible_mode:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false

func _process(delta: float):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset
	elif speed != 0:
		global_position += bounce_velocity * delta
		_check_bounds()

#Automatic cycle for hiding and showing
func _cycle_mode():
	while cycle:
		if is_visible_mode:
			hide_with_pop()
			await get_tree().create_timer(disappear_time).timeout
			
		else:
			show_with_pop()
			await get_tree().create_timer(appear_time).timeout

#Animations
func show_with_pop():
	is_visible_mode = true
	timer = 0.0
	input_pickable = true
	
	_sprite.visible = true
	_sprite.scale = Vector2.ZERO
	if _tween: _tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	var duration = 0.5
	_tween.tween_property(_sprite, "scale", Vector2.ONE, duration)

#Hiding bone temporarily at intervals
func hide_with_pop():
	is_visible_mode = false
	timer = 0.0
	input_pickable = false
	
	if _tween: _tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	
	var duration = 0.3
	_tween.tween_property(_sprite, "scale", Vector2.ZERO, duration)
	_tween.finished.connect(func(): 
		_sprite.visible = false
		dragging = false)
	
	
#Function to keep bone within a certain area
func _check_bounds():
	var screen_size = food_float_area.get_node("CollisionShape2D").shape.extents * 2
	
	#Multiply by -1 to flip direction
	if not dragging:
		global_position = global_position.clamp(Vector2.ZERO, screen_size)
	
		if global_position.x == 0 or global_position.x == screen_size.x:
			bounce_velocity.x *= -1
		if global_position.y == 0 or global_position.y == screen_size.y:
			bounce_velocity.y *= -1
	
		
#To sense when bone has touched bowl
func on_bowl(body):
	#When it touches bowl, it hide with pop
	if body is CharacterBody2D and dragging:
		is_on_bowl = true
		hide_with_pop()
#To sense when bone has stopped touching bowl	
func out_bowl(body):
	if body is CharacterBody2D:
		is_on_bowl = false
