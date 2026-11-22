extends CharacterBody3D

@export var move_speed := 3.2
@export var mouse_sensitivity := 0.0022
var camera: Camera3D
var touch_actions: Dictionary = {}
var look_touch_id := -1
var gravity := 18.0

func _ready() -> void:
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.65
	collider.shape = capsule
	collider.position.y = 0.82
	add_child(collider)
	camera = Camera3D.new()
	camera.position = Vector3(0, 1.48, 0)
	camera.current = true
	add_child(camera)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or touch_actions.get("forward", false):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or touch_actions.get("back", false):
		input_vector.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or touch_actions.get("left", false):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or touch_actions.get("right", false):
		input_vector.x += 1.0
	input_vector = input_vector.normalized()
	var direction := (global_transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func set_touch_action(action: String, pressed: bool) -> void:
	touch_actions[action] = pressed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotate_view(event.relative)
	elif event is InputEventScreenTouch:
		if event.pressed and event.position.x > get_viewport().get_visible_rect().size.x * 0.45:
			look_touch_id = event.index
		elif not event.pressed and event.index == look_touch_id:
			look_touch_id = -1
	elif event is InputEventScreenDrag and event.index == look_touch_id:
		_rotate_view(event.relative * 1.0)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _rotate_view(relative: Vector2) -> void:
	rotate_y(-relative.x * mouse_sensitivity)
	camera.rotation.x = clampf(camera.rotation.x - relative.y * mouse_sensitivity, deg_to_rad(-75), deg_to_rad(75))
