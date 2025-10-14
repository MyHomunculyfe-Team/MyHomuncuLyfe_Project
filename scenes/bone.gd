extends CharacterBody2D

@export var speed: float = 200.0
@export var appear_time: float = 5.0   # how long it's visible
@export var disappear_time: float = 3.0  # how long it's hidden
@export var FoodFloatArea: Area2D

var dragging := false
var drag_offset := Vector2.ZERO
var moving_dir := Vector2(1, 1).normalized()

var is_visible_mode := false
var timer := 0.0
var bounce_velocity
var is_on_bowl = false

@onready var sprite := $Sprite2D  
var tween: Tween

func _ready():
	randomize() # pick a random diagonal direction 
	var angle = randf_range(0.0, TAU) 
	bounce_velocity = Vector2(cos(angle), sin(angle)) * speed
	
	input_pickable = false
	sprite.visible = false
	_cycle_mode()  # start automatic loop

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
	else:
		global_position += bounce_velocity * delta
		_check_bounds()

#Automatic cycle for hiding and showing
func _cycle_mode():
	if is_visible_mode:
		hide_with_pop()
		await get_tree().create_timer(disappear_time).timeout
		
	else:
		show_with_pop()
		await get_tree().create_timer(appear_time).timeout
	
	_cycle_mode()  # loop forever

#Animations
func show_with_pop():
	is_visible_mode = true
	timer = 0.0
	input_pickable = true
	
	sprite.visible = true
	sprite.scale = Vector2.ZERO
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.5)

#Hiding bone temporarily at intervals
func hide_with_pop():
	is_visible_mode = false
	timer = 0.0
	input_pickable = false
	
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.3)
	tween.finished.connect(func(): 
		sprite.visible = false
		dragging = false)
	
	
#Function to keep bone within a certain area
func _check_bounds():
	var screen_size = FoodFloatArea.get_node("CollisionShape2D").shape.extents * 2
	
	if not dragging:
		if global_position.x <= 0: 
			global_position.x = 0 
			bounce_velocity.x *= -1 
		elif global_position.x >= screen_size.x: 
			global_position.x = screen_size.x 
			bounce_velocity.x *= -1
	
		if global_position.y <= 0: 
			global_position.y = 0 
			bounce_velocity.y *= -1 
		elif global_position.y >= screen_size.y: 
			global_position.y = screen_size.y 
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
