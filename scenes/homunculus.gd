extends CharacterBody2D

@export var target_position: Vector2 = Vector2(randf_range(200,1200), 800)
@export var speed: float = 120.0
@export var gravity: float = 400.0
@export var bowl: CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var points: int = 10
@onready var bowl_timer: Timer = $BowlTimer

var bowl_coords

var base_sprite_scale: Vector2
var base_polygon_points: PackedVector2Array

var move = false
var is_squashing = false
var dragging = false
var drag_offset = Vector2.ZERO
var is_touching_table_floor = false
var is_jumping = false
var is_on_bowl = false

func _ready():
	input_pickable = true
	base_sprite_scale = $AnimatedSprite2D.scale
	base_polygon_points = $CollisionPolygon2D.polygon.duplicate()
	bowl_coords = bowl.get_node("Area2D").get_node("CollisionShape2D").global_position
	target_position = Vector2(randf_range(200,1200), 800)
	sprite.frame = 0
	
	bowl_timer.wait_time = 0.5
	bowl_timer.one_shot = false
	bowl_timer.connect("timeout", Callable(self, "_on_bowl_timer_tick"))
	

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:#If mouse clicked
		if event.pressed:
			dragging = true
			drag_offset = global_position - get_global_mouse_position() #calculates the distance between mouse and character
		else:
			dragging = false

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false

func _process(delta: float):
	move = true
	
	#setting value of size
	var min_scale = 1.0
	var max_scale = 2.0
	var far_distance = 100
	var near_distance = 500
	
	var distance = (position.y - far_distance) / near_distance
	
	if not is_jumping:
		scale.x = lerp(min_scale, max_scale, distance)
		scale.y = lerp(min_scale, max_scale, distance)
	
	if dragging:
		move = false
		target_position = Vector2(randf_range(200,1200), 800)
		if is_jumping:
			tween_to_drag_scale()
			is_jumping = false
		
		global_position = get_global_mouse_position() + drag_offset #set position to mouse posiiton plus the distance
		velocity = Vector2.ZERO #not moving


func _physics_process(delta: float):
	
	if not is_jumping:
		var to_target := target_position - global_position #difference between target and character
		if to_target.length() > 2.0 :#move to target 
			move = true
			velocity = to_target.normalized() * speed
			move_and_slide()

			if not is_squashing and not dragging:
				_start_squash()
				
		else:#reached the bowl
			velocity = Vector2.ZERO
			move = false
	
	if is_jumping:
		velocity.y += gravity * delta
		move_and_slide()

	# check if reached bowl
	if global_position.distance_to(bowl_coords) < 4.0:
		is_jumping = false
		velocity = Vector2.ZERO
		global_position = bowl_coords
		sprite.frame = 1
		sprite.z_index = 10
	else:
		sprite.frame = 0
		sprite.z_index = 0


func _on_table_floor(body):
	if body is CharacterBody2D:
		is_touching_table_floor = true
		jump_to_target(bowl_coords)
		print("on floor")

func _off_table_floor(body):
	if body is CharacterBody2D:
		is_touching_table_floor = false
		print("Munc left the table floor")
		
func _on_bowl(body):
	if body is CharacterBody2D:
		is_on_bowl = true
		if not bowl_timer.is_stopped():
			bowl_timer.stop()  # Reset timer if it was already running
		bowl_timer.start()
		

func _off_bowl(body):
	if body is CharacterBody2D:
		is_on_bowl = false
		bowl_timer.stop()
		
func _on_bowl_timer_tick():
	points = max(points - 1, 0)  # prevent negative points
	print("Points:", points)
		
		
func _start_squash():
	is_squashing = true
	var tween = create_tween()

	tween.tween_property($AnimatedSprite2D, "scale", $AnimatedSprite2D.scale * Vector2(1.2, 0.9), 0.1)
	tween.tween_property($AnimatedSprite2D, "scale", $AnimatedSprite2D.scale, 0.1)

	tween.finished.connect(func(): is_squashing = false)
	
func tween_to_drag_scale():
	var min_scale = 1.0
	var max_scale = 2.0
	var far_distance = 100
	var near_distance = 500

	var distance = (position.y - far_distance) / near_distance
	var target_scale = Vector2(lerp(min_scale, max_scale, distance),lerp(min_scale, max_scale, distance))

	var tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 0.1) # duration = 0.3 sec (adjust)
	
func jump_to_target(end_position: Vector2, jump_height: float = 300.0):
	print("going to ",end_position)
	is_jumping = true
	var start = global_position
	var dy = start.y - end_position.y  # positive if jumping up
	# initial vertical speed for the desired jump height
	var v_y = sqrt(2 * gravity * jump_height)
	# total time to land (approx)
	var t_total = (2 * v_y) / gravity
	# horizontal speed to reach target
	var v_x = (end_position.x - start.x) / t_total
	velocity = Vector2(v_x, -v_y)

func add_points(amount: int):
	points += amount
	print("Points:", points)

func subtract_points(amount: int):
	points = max(points - amount, 0) # prevent negative points
	print("Points:", points)
	
