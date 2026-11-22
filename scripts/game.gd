extends Node3D

var player: CharacterBody3D
var key_node: Node3D
var exit_door: MeshInstance3D
var ghost_node: Node3D
var hud_label: Label
var message_label: Label
var has_key := false
var ghost_active := false
var ghost_lifetime := 0.0
var won := false

func _ready() -> void:
	_build_house()
	_build_player()
	_build_hud()
	_show_message("DISPATCH: Check the house. Find a way out.", 5.0)

func _process(delta: float) -> void:
	if won:
		return
	if not has_key and player.global_position.distance_to(key_node.global_position) < 1.35:
		has_key = true
		key_node.queue_free()
		hud_label.text = "EVIDENCE KEY: FOUND"
		_show_message("You found a key. Something moved upstairs...", 4.0)
		_start_ghost_event()
	if has_key and player.global_position.distance_to(Vector3(0, 0, -7.0)) < 2.0:
		won = true
		exit_door.visible = false
		_show_message("EXIT UNLOCKED  •  CASE FILE COMPLETE", 999.0)
		player.set_physics_process(false)
	if ghost_active:
		ghost_lifetime -= delta
		if ghost_lifetime <= 0.0:
			ghost_node.visible = false
			ghost_active = false

func _build_house() -> void:
	_add_box("Floor", Vector3(0, -0.25, 0), Vector3(16, 0.5, 16), Color("#24272b"))
	_add_box("Ceiling", Vector3(0, 3.55, 0), Vector3(16, 0.25, 16), Color("#171a20"))
	_add_box("West wall", Vector3(-8, 1.65, 0), Vector3(0.3, 3.3, 16), Color("#343238"))
	_add_box("East wall", Vector3(8, 1.65, 0), Vector3(0.3, 3.3, 16), Color("#343238"))
	_add_box("Front wall", Vector3(0, 1.65, 8), Vector3(16, 3.3, 0.3), Color("#343238"))
	_add_box("Back wall left", Vector3(-5.2, 1.65, -8), Vector3(5.6, 3.3, 0.3), Color("#343238"))
	_add_box("Back wall right", Vector3(5.2, 1.65, -8), Vector3(5.6, 3.3, 0.3), Color("#343238"))
	_add_box("Hall partition left", Vector3(-4.6, 1.5, -2.5), Vector3(6.8, 3, 0.22), Color("#292b31"))
	_add_box("Hall partition right", Vector3(5.6, 1.5, -2.5), Vector3(4.8, 3, 0.22), Color("#292b31"))
	_add_box("Old table", Vector3(-4.2, 0.65, 2.0), Vector3(2.1, 1.3, 1.1), Color("#49372d"))
	_add_box("Cabinet", Vector3(5.8, 1.0, 4.0), Vector3(1.2, 2.0, 1.0), Color("#302b30"))
	_add_box("Crate", Vector3(3.5, 0.55, -4.8), Vector3(1.2, 1.1, 1.2), Color("#514237"))
	_add_box("Exit frame top", Vector3(0, 3.05, -7.85), Vector3(2.6, 0.25, 0.25), Color("#75614a"))
	_add_box("Exit frame left", Vector3(-1.25, 1.5, -7.85), Vector3(0.2, 3.0, 0.25), Color("#75614a"))
	_add_box("Exit frame right", Vector3(1.25, 1.5, -7.85), Vector3(0.2, 3.0, 0.25), Color("#75614a"))
	exit_door = _make_box_visual("Locked exit", Vector3(0, 1.5, -7.82), Vector3(2.25, 2.9, 0.18), Color("#382b2a"))
	_add_box("Door handle", Vector3(0.82, 1.45, -7.68), Vector3(0.08, 0.28, 0.08), Color("#c7a76a"), false)
	key_node = Node3D.new()
	key_node.position = Vector3(-4.0, 0.75, -3.7)
	add_child(key_node)
	var key_mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.44
	key_mesh.mesh = sphere
	key_mesh.material_override = _material(Color("#d7b65f"), 0.25, 0.8)
	key_node.add_child(key_mesh)
	var key_light := OmniLight3D.new()
	key_light.light_color = Color("#e5c77c")
	key_light.light_energy = 0.7
	key_light.omni_range = 3.0
	key_node.add_child(key_light)
	ghost_node = _make_ghost()
	ghost_node.position = Vector3(0, 0, -1.0)
	ghost_node.visible = false
	add_child(ghost_node)
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#536071")
	env.ambient_light_energy = 0.22
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	add_child(world_env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.light_energy = 0.18
	add_child(light)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.7, 1)
	lamp.light_color = Color("#b9c8dc")
	lamp.light_energy = 0.65
	lamp.omni_range = 9.0
	add_child(lamp)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "PoliceOfficer"
	player.position = Vector3(0, 0.1, 5.5)
	player.set_script(load("res://scripts/player.gd"))
	add_child(player)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.color = Color(0.02, 0.03, 0.05, 0.62)
	panel.position = Vector2(18, 18)
	panel.size = Vector2(330, 82)
	layer.add_child(panel)
	hud_label = Label.new()
	hud_label.position = Vector2(32, 27)
	hud_label.text = "POLICE RADIO: SIGNAL LOST"
	hud_label.add_theme_color_override("font_color", Color("#d9e0e8"))
	hud_label.add_theme_font_size_override("font_size", 19)
	layer.add_child(hud_label)
	message_label = Label.new()
	message_label.anchor_left = 0.18
	message_label.anchor_right = 0.82
	message_label.anchor_top = 0.78
	message_label.anchor_bottom = 0.96
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_color_override("font_color", Color("#f0e9dc"))
	message_label.add_theme_font_size_override("font_size", 22)
	layer.add_child(message_label)
	var hint := Label.new()
	hint.anchor_left = 0.3
	hint.anchor_right = 0.7
	hint.anchor_top = 0.03
	hint.anchor_bottom = 0.1
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.text = "LEFT SIDE: MOVE     •     DRAG RIGHT: LOOK"
	hint.add_theme_color_override("font_color", Color("#aeb9c7"))
	hint.add_theme_font_size_override("font_size", 14)
	layer.add_child(hint)
	_add_touch_button(layer, "▲", Vector2(112, -176), "forward")
	_add_touch_button(layer, "▼", Vector2(112, -72), "back")
	_add_touch_button(layer, "◀", Vector2(60, -124), "left")
	_add_touch_button(layer, "▶", Vector2(164, -124), "right")

func _add_touch_button(layer: CanvasLayer, label_text: String, offset: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = label_text
	button.size = Vector2(48, 48)
	button.anchor_left = 0.0
	button.anchor_right = 0.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = offset.x
	button.offset_right = offset.x + 48
	button.offset_top = offset.y
	button.offset_bottom = offset.y + 48
	button.modulate = Color(1, 1, 1, 0.78)
	button.add_theme_font_size_override("font_size", 20)
	button.button_down.connect(Callable(player, "set_touch_action").bind(action, true))
	button.button_up.connect(Callable(player, "set_touch_action").bind(action, false))
	layer.add_child(button)

func _start_ghost_event() -> void:
	ghost_node.visible = true
	ghost_active = true
	ghost_lifetime = 1.7
	_show_message("...", 2.0)

func _show_message(value: String, duration: float) -> void:
	message_label.text = value
	if duration < 900.0:
		var timer := get_tree().create_timer(duration)
		timer.timeout.connect(func():
			if is_instance_valid(message_label) and not won:
				message_label.text = ""
		)

func _make_ghost() -> Node3D:
	var ghost := Node3D.new()
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.9
	body.mesh = capsule
	body.position.y = 1.0
	body.material_override = _material(Color(0.78, 0.84, 0.91, 0.72), 0.0, 0.0)
	ghost.add_child(body)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.36
	head_mesh.height = 0.72
	head.mesh = head_mesh
	head.position = Vector3(0, 2.0, 0)
	head.material_override = _material(Color(0.86, 0.89, 0.94, 0.82), 0.0, 0.0)
	ghost.add_child(head)
	return ghost

func _add_box(label: String, position_value: Vector3, size_value: Vector3, color: Color, collision := true) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = position_value
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size_value
	mesh_instance.mesh = box
	mesh_instance.material_override = _material(color)
	body.add_child(mesh_instance)
	if collision:
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size_value
		shape.shape = box_shape
		body.add_child(shape)
	add_child(body)

func _make_box_visual(label: String, position_value: Vector3, size_value: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.position = position_value
	var box := BoxMesh.new()
	box.size = size_value
	instance.mesh = box
	instance.material_override = _material(color)
	add_child(instance)
	return instance

func _material(color: Color, roughness := 0.9, metallic := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material
