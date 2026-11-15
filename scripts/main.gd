extends Node3D

const SAVE_PATH := "user://day_long_save.json"
const WALK_SPEED := 6.2
const JUMP_SPEED := 7.0
const WORLD_SIZE := 210.0

var rng := RandomNumberGenerator.new()
var player: CharacterBody3D
var camera_pivot: Node3D
var game_camera: Camera3D
var sun: DirectionalLight3D
var touch_axis := Vector2.ZERO
var camera_yaw := 0.0
var camera_pitch := -0.18
var look_finger_id := -1
var inventory := {"Wood": 0, "Stone": 0, "Berries": 0}
var resources: Array[Dictionary] = []
var hunger := 100.0
var thirst := 100.0
var survival_timer := 0.0
var world_clock := 0.22
var hud_timer := 0.0
var message_timer := 0.0
var shelter_built := false
var stats_label: Label
var mission_label: Label
var prompt_label: Label
var message_label: Label
var day_label: Label

func _ready() -> void:
	rng.seed = 8142026
	_create_environment()
	_create_world()
	_create_player()
	_create_hud()
	_load_game()
	_refresh_hud()

func _process(delta: float) -> void:
	world_clock += delta / 520.0
	if world_clock >= 1.0:
		world_clock = 0.0
	survival_timer += delta
	if survival_timer >= 42.0:
		survival_timer = 0.0
		hunger = maxf(0.0, hunger - 1.0)
		thirst = maxf(0.0, thirst - 1.5)
		_save_game()
	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0 and is_instance_valid(message_label):
			message_label.text = ""
	if is_instance_valid(sun):
		var angle := world_clock * TAU
		sun.rotation_degrees = Vector3(-36.0 + sin(angle) * 13.0, -35.0 + world_clock * 360.0, 0.0)
		sun.light_energy = 0.35 + 0.65 * maxf(0.0, sin(angle + 0.65))
	hud_timer += delta
	if hud_timer >= 0.2:
		hud_timer = 0.0
		_refresh_hud()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var keyboard := Vector2.ZERO
	keyboard.x = float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A))
	keyboard.y = float(Input.is_key_pressed(KEY_W)) - float(Input.is_key_pressed(KEY_S))
	var move_input := touch_axis + Vector2(keyboard.x, -keyboard.y)
	if move_input.length() > 1.0:
		move_input = move_input.normalized()
	var forward := -camera_pivot.global_basis.z
	var right := camera_pivot.global_basis.x
	var direction := right * move_input.x + forward * (-move_input.y)
	direction.y = 0.0
	if direction.length() > 1.0:
		direction = direction.normalized()
	if direction.length_squared() > 0.01:
		player.rotation.y = lerp_angle(player.rotation.y, atan2(-direction.x, -direction.z), minf(1.0, 10.0 * delta))
	player.velocity.x = direction.x * WALK_SPEED
	player.velocity.z = direction.z * WALK_SPEED
	if not player.is_on_floor():
		player.velocity.y -= 24.0 * delta
	elif player.velocity.y < 0.0:
		player.velocity.y = 0.0
	player.move_and_slide()
	camera_pivot.global_position = player.global_position + Vector3(0.0, 1.55, 0.0)

func _create_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.19, 0.37, 0.52)
	sky_material.sky_horizon_color = Color(0.72, 0.77, 0.68)
	sky_material.ground_bottom_color = Color(0.12, 0.18, 0.13)
	sky_material.ground_horizon_color = Color(0.48, 0.54, 0.43)
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.58, 0.65, 0.54)
	environment.ambient_light_energy = 0.75
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment
	add_child(world_environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-36.0, -35.0, 0.0)
	sun.light_color = Color(1.0, 0.91, 0.75)
	sun.light_energy = 0.9
	sun.shadow_enabled = true
	add_child(sun)

func _create_world() -> void:
	var ground := StaticBody3D.new()
	ground.name = "WorldGround"
	ground.position.y = -0.5
	add_child(ground)
	var ground_shape := CollisionShape3D.new()
	var ground_box := BoxShape3D.new()
	ground_box.size = Vector3(WORLD_SIZE, 1.0, WORLD_SIZE)
	ground_shape.shape = ground_box
	ground.add_child(ground_shape)
	var ground_visual := MeshInstance3D.new()
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(WORLD_SIZE, WORLD_SIZE)
	ground_visual.mesh = ground_mesh
	ground_visual.position.y = 0.5
	ground_visual.material_override = _material(Color(0.25, 0.36, 0.22))
	ground.add_child(ground_visual)

	var river := MeshInstance3D.new()
	var river_mesh := PlaneMesh.new()
	river_mesh.size = Vector2(12.0, 150.0)
	river.mesh = river_mesh
	river.position = Vector3(34.0, 0.025, -7.0)
	river.material_override = _material(Color(0.16, 0.42, 0.54))
	add_child(river)

	for i in range(13):
		var ridge := MeshInstance3D.new()
		var ridge_mesh := SphereMesh.new()
		ridge_mesh.radius = rng.randf_range(8.0, 15.0)
		ridge_mesh.height = ridge_mesh.radius * 1.6
		ridge_mesh.radial_segments = 12
		ridge_mesh.rings = 6
		ridge.mesh = ridge_mesh
		var angle := TAU * float(i) / 13.0
		ridge.position = Vector3(cos(angle) * 91.0, -4.0, sin(angle) * 91.0)
		ridge.scale = Vector3(1.8, 1.0, 1.8)
		ridge.material_override = _material(Color(0.20, 0.29, 0.27))
		add_child(ridge)

	for i in range(52):
		var angle := rng.randf_range(0.0, TAU)
		var distance := rng.randf_range(18.0, 88.0)
		var location := Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
		if absf(location.x - 34.0) < 8.0:
			continue
		_create_tree(location)
	for i in range(17):
		var location := Vector3(rng.randf_range(-74.0, 74.0), 0.0, rng.randf_range(-74.0, 74.0))
		if location.length() < 10.0 or absf(location.x - 34.0) < 8.0:
			continue
		_create_rock(location)
	for i in range(12):
		_spawn_resource("Wood", Vector3(rng.randf_range(-15.0, 15.0), 0.0, rng.randf_range(-18.0, 18.0)))
	for i in range(9):
		_spawn_resource("Stone", Vector3(rng.randf_range(-17.0, 17.0), 0.0, rng.randf_range(-20.0, 20.0)))
	for i in range(8):
		_spawn_resource("Berries", Vector3(rng.randf_range(-20.0, 20.0), 0.0, rng.randf_range(-22.0, 22.0)))

func _create_tree(location: Vector3) -> void:
	var tree := StaticBody3D.new()
	tree.position = location
	add_child(tree)
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.22
	trunk_mesh.bottom_radius = 0.38
	trunk_mesh.height = 2.8
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.4
	trunk.material_override = _material(Color(0.31, 0.20, 0.12))
	tree.add_child(trunk)
	var trunk_collision := CollisionShape3D.new()
	var trunk_shape := CylinderShape3D.new()
	trunk_shape.radius = 0.34
	trunk_shape.height = 2.8
	trunk_collision.shape = trunk_shape
	trunk_collision.position.y = 1.4
	tree.add_child(trunk_collision)
	var canopy := MeshInstance3D.new()
	var canopy_mesh := SphereMesh.new()
	canopy_mesh.radius = rng.randf_range(1.35, 1.85)
	canopy_mesh.height = canopy_mesh.radius * 1.65
	canopy_mesh.radial_segments = 12
	canopy_mesh.rings = 7
	canopy.mesh = canopy_mesh
	canopy.position.y = 3.1
	canopy.scale = Vector3(1.05, 1.15, 1.0)
	var greens := [Color(0.17, 0.31, 0.18), Color(0.22, 0.37, 0.21), Color(0.27, 0.39, 0.23)]
	canopy.material_override = _material(greens[rng.randi_range(0, greens.size() - 1)])
	tree.add_child(canopy)

func _create_rock(location: Vector3) -> void:
	var rock := StaticBody3D.new()
	rock.position = location
	add_child(rock)
	var visual := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = rng.randf_range(0.55, 1.0)
	sphere.height = sphere.radius * 1.25
	sphere.radial_segments = 10
	sphere.rings = 5
	visual.mesh = sphere
	visual.position.y = sphere.radius * 0.55
	visual.scale = Vector3(1.25, 0.8, 1.0)
	visual.material_override = _material(Color(0.39, 0.42, 0.39))
	rock.add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = sphere.radius * 0.9
	collision.shape = shape
	collision.position.y = sphere.radius * 0.55
	rock.add_child(collision)

func _spawn_resource(kind: String, location: Vector3) -> void:
	var area := Area3D.new()
	area.name = kind + "Pickup"
	area.position = location
	area.collision_layer = 0
	area.collision_mask = 0
	add_child(area)
	var visual := MeshInstance3D.new()
	if kind == "Wood":
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.16
		mesh.bottom_radius = 0.19
		mesh.height = 1.15
		visual.mesh = mesh
		visual.rotation.z = PI * 0.5
		visual.position.y = 0.35
		visual.material_override = _material(Color(0.50, 0.31, 0.16))
	elif kind == "Stone":
		var mesh := SphereMesh.new()
		mesh.radius = 0.42
		mesh.height = 0.62
		mesh.radial_segments = 10
		mesh.rings = 5
		visual.mesh = mesh
		visual.position.y = 0.28
		visual.material_override = _material(Color(0.54, 0.58, 0.55))
	else:
		var mesh := SphereMesh.new()
		mesh.radius = 0.38
		mesh.height = 0.55
		mesh.radial_segments = 10
		mesh.rings = 5
		visual.mesh = mesh
		visual.position.y = 0.38
		visual.material_override = _material(Color(0.55, 0.18, 0.25))
	area.add_child(visual)
	var trigger := CollisionShape3D.new()
	var trigger_shape := SphereShape3D.new()
	trigger_shape.radius = 1.35
	trigger.shape = trigger_shape
	trigger.position.y = 0.5
	area.add_child(trigger)
	resources.append({"area": area, "kind": kind})

func _create_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0.0, 0.12, 2.0)
	add_child(player)
	var body_visual := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.38
	body_mesh.height = 1.65
	body_visual.mesh = body_mesh
	body_visual.position.y = 0.88
	body_visual.material_override = _material(Color(0.27, 0.39, 0.34))
	player.add_child(body_visual)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.27
	head_mesh.height = 0.54
	head.mesh = head_mesh
	head.position = Vector3(0.0, 1.78, 0.0)
	head.material_override = _material(Color(0.72, 0.54, 0.40))
	player.add_child(head)
	var collision := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.38
	capsule_shape.height = 1.8
	collision.shape = capsule_shape
	collision.position.y = 0.9
	player.add_child(collision)
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	camera_pivot.global_position = player.global_position + Vector3(0.0, 1.55, 0.0)
	game_camera = Camera3D.new()
	game_camera.position = Vector3(0.0, 0.25, 6.4)
	game_camera.current = true
	game_camera.fov = 68.0
	camera_pivot.add_child(game_camera)
	_update_camera_rotation()

func _create_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 5
	add_child(canvas)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)

	var title := _make_label(root, "DAY LONG ADDICT", 0.03, 0.025, 0.48, 0.085, 26)
	title.add_theme_color_override("font_color", Color(0.98, 0.93, 0.78))
	stats_label = _make_label(root, "", 0.03, 0.09, 0.54, 0.205, 19)
	stats_label.add_theme_color_override("font_color", Color(0.96, 0.96, 0.89))
	mission_label = _make_label(root, "", 0.03, 0.215, 0.60, 0.29, 16)
	mission_label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.68))
	day_label = _make_label(root, "", 0.78, 0.035, 0.97, 0.09, 18)
	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	prompt_label = _make_label(root, "Explore the clearing. Gather supplies nearby.", 0.29, 0.82, 0.68, 0.93, 17)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_color_override("font_color", Color(0.98, 0.95, 0.84))
	message_label = _make_label(root, "", 0.25, 0.42, 0.75, 0.52, 22)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.62))

	var look_area := Control.new()
	look_area.name = "LookArea"
	look_area.anchor_left = 0.47
	look_area.anchor_top = 0.16
	look_area.anchor_right = 0.99
	look_area.anchor_bottom = 0.60
	look_area.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(look_area)
	look_area.gui_input.connect(_on_look_input)

	var stick := Control.new()
	stick.set_script(load("res://scripts/touch_stick.gd"))
	stick.anchor_left = 0.025
	stick.anchor_top = 0.66
	stick.anchor_right = 0.265
	stick.anchor_bottom = 0.98
	root.add_child(stick)
	stick.connect("vector_changed", _on_stick_changed)

	_make_button(root, "BUILD", 0.84, 0.62, 0.98, 0.75, _build_shelter)
	_make_button(root, "GATHER", 0.84, 0.78, 0.98, 0.92, _collect_nearest)
	_make_button(root, "JUMP", 0.68, 0.64, 0.81, 0.77, _jump)
	_make_button(root, "EAT", 0.68, 0.81, 0.81, 0.93, _eat_berries)

func _make_label(parent: Control, value: String, left: float, top: float, right: float, bottom: float, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.anchor_left = left
	label.anchor_top = top
	label.anchor_right = right
	label.anchor_bottom = bottom
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_shadow_color", Color(0.02, 0.04, 0.03, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func _make_button(parent: Control, title: String, left: float, top: float, right: float, bottom: float, callback: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.anchor_left = left
	button.anchor_top = top
	button.anchor_right = right
	button.anchor_bottom = bottom
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(0.97, 0.95, 0.85))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.15, 0.12, 0.92)
	normal.border_color = Color(0.65, 0.73, 0.57, 0.9)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(14)
	normal.content_margin_left = 8.0
	normal.content_margin_right = 8.0
	normal.content_margin_top = 6.0
	normal.content_margin_bottom = 6.0
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.20, 0.29, 0.20, 0.98)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", pressed)
	button.add_theme_stylebox_override("pressed", pressed)
	button.pressed.connect(callback)
	parent.add_child(button)

func _on_stick_changed(value: Vector2) -> void:
	touch_axis = value

func _on_look_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and look_finger_id == -1:
			look_finger_id = event.index
		elif not event.pressed and event.index == look_finger_id:
			look_finger_id = -1
	elif event is InputEventScreenDrag and event.index == look_finger_id:
		_rotate_camera(event.relative)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_rotate_camera(event.relative)

func _rotate_camera(delta_position: Vector2) -> void:
	camera_yaw -= delta_position.x * 0.006
	camera_pitch = clampf(camera_pitch - delta_position.y * 0.004, -0.62, 0.12)
	_update_camera_rotation()

func _update_camera_rotation() -> void:
	if is_instance_valid(camera_pivot):
		camera_pivot.rotation = Vector3(camera_pitch, camera_yaw, 0.0)

func _jump() -> void:
	if is_instance_valid(player) and player.is_on_floor():
		player.velocity.y = JUMP_SPEED

func _collect_nearest() -> void:
	if not is_instance_valid(player):
		return
	var nearest_index := -1
	var nearest_distance := 9999.0
	for i in range(resources.size()):
		var area = resources[i].get("area")
		if not is_instance_valid(area):
			continue
		var distance := player.global_position.distance_to(area.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = i
	if nearest_index == -1 or nearest_distance > 4.2:
		_show_message("Move closer to a supply first.")
		return
	var item: Dictionary = resources[nearest_index]
	var kind: String = item.get("kind", "Wood")
	inventory[kind] = int(inventory.get(kind, 0)) + 1
	var picked_area = item.get("area")
	if is_instance_valid(picked_area):
		picked_area.queue_free()
	resources.remove_at(nearest_index)
	_show_message("Collected 1 " + kind + ".")
	_save_game()
	_refresh_hud()

func _build_shelter() -> void:
	if shelter_built:
		_show_message("Your shelter is already built.")
		return
	if int(inventory["Wood"]) < 3 or int(inventory["Stone"]) < 2:
		_show_message("Shelter needs 3 wood and 2 stone.")
		return
	inventory["Wood"] = int(inventory["Wood"]) - 3
	inventory["Stone"] = int(inventory["Stone"]) - 2
	shelter_built = true
	var shelter := Node3D.new()
	shelter.name = "PlayerShelter"
	shelter.position = player.global_position + Vector3(0.0, 0.0, -4.0)
	add_child(shelter)
	_add_box(shelter, Vector3(-1.0, 0.7, 0.0), Vector3(0.18, 1.4, 2.4), Color(0.43, 0.27, 0.14))
	_add_box(shelter, Vector3(1.0, 0.7, 0.0), Vector3(0.18, 1.4, 2.4), Color(0.43, 0.27, 0.14))
	_add_box(shelter, Vector3(0.0, 1.45, 0.0), Vector3(2.3, 0.16, 2.4), Color(0.30, 0.25, 0.17))
	_add_box(shelter, Vector3(0.0, 0.95, -1.1), Vector3(2.3, 0.16, 0.16), Color(0.48, 0.32, 0.18))
	var fire_pit := MeshInstance3D.new()
	var fire_mesh := CylinderMesh.new()
	fire_mesh.top_radius = 0.48
	fire_mesh.bottom_radius = 0.55
	fire_mesh.height = 0.16
	fire_pit.mesh = fire_mesh
	fire_pit.position = Vector3(2.0, 0.08, 0.8)
	fire_pit.material_override = _material(Color(0.27, 0.27, 0.24))
	shelter.add_child(fire_pit)
	_show_message("Shelter built! You have a base for the night.")
	_save_game()
	_refresh_hud()

func _add_box(parent: Node3D, location: Vector3, dimensions: Vector3, tint: Color) -> void:
	var visual := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = dimensions
	visual.mesh = box
	visual.position = location
	visual.material_override = _material(tint)
	parent.add_child(visual)

func _eat_berries() -> void:
	if int(inventory["Berries"]) <= 0:
		_show_message("No berries in your bag.")
		return
	inventory["Berries"] = int(inventory["Berries"]) - 1
	hunger = minf(100.0, hunger + 18.0)
	thirst = minf(100.0, thirst + 5.0)
	_show_message("You ate some berries. A little more energy.")
	_save_game()
	_refresh_hud()

func _show_message(value: String) -> void:
	if is_instance_valid(message_label):
		message_label.text = value
		message_timer = 2.7

func _refresh_hud() -> void:
	if not is_instance_valid(stats_label):
		return
	stats_label.text = "WOOD  %02d     STONE  %02d     BERRIES  %02d\nHUNGER  %d%%     THIRST  %d%%" % [
		int(inventory["Wood"]), int(inventory["Stone"]), int(inventory["Berries"]),
		int(hunger), int(thirst)
	]
	mission_label.text = "TASK: Build a shelter   |   %d/3 wood   %d/2 stone" % [
		int(minf(3.0, float(inventory["Wood"]))), int(minf(2.0, float(inventory["Stone"])))
	]
	var phase := "DAY" if sin(world_clock * TAU + 0.65) > 0.05 else "NIGHT"
	day_label.text = "DAY %d  •  %s" % [int(world_clock) + 1, phase]
	var nearest_distance := 9999.0
	var nearest_kind := ""
	if is_instance_valid(player):
		for item in resources:
			var area = item.get("area")
			if is_instance_valid(area):
				var distance := player.global_position.distance_to(area.global_position)
				if distance < nearest_distance:
					nearest_distance = distance
					nearest_kind = str(item.get("kind", "supply"))
	if nearest_distance <= 4.2:
		prompt_label.text = "Nearby: %s  •  Tap GATHER" % nearest_kind.to_upper()
	else:
		prompt_label.text = "Explore the clearing and look for supplies."

func _material(tint: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.92
	return material

func _save_game() -> void:
	if not is_instance_valid(player):
		return
	var data := {
		"wood": inventory["Wood"],
		"stone": inventory["Stone"],
		"berries": inventory["Berries"],
		"hunger": hunger,
		"thirst": thirst,
		"shelter_built": shelter_built,
		"position": [player.global_position.x, player.global_position.y, player.global_position.z]
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var data = JSON.parse_string(file.get_as_text())
	if not data is Dictionary:
		return
	inventory["Wood"] = int(data.get("wood", 0))
	inventory["Stone"] = int(data.get("stone", 0))
	inventory["Berries"] = int(data.get("berries", 0))
	hunger = clampf(float(data.get("hunger", 100.0)), 0.0, 100.0)
	thirst = clampf(float(data.get("thirst", 100.0)), 0.0, 100.0)
	shelter_built = bool(data.get("shelter_built", false))
	var saved_position = data.get("position", [])
	if saved_position is Array and saved_position.size() >= 3:
		player.global_position = Vector3(float(saved_position[0]), float(saved_position[1]), float(saved_position[2]))
	if shelter_built:
		var marker := MeshInstance3D.new()
		var marker_mesh := BoxMesh.new()
		marker_mesh.size = Vector3(2.0, 1.1, 1.6)
		marker.mesh = marker_mesh
		marker.position = player.global_position + Vector3(0.0, 0.55, -4.0)
		marker.material_override = _material(Color(0.43, 0.30, 0.18))
		add_child(marker)

func _exit_tree() -> void:
	_save_game()
