extends Node3D

const INTERACT_DISTANCE := 2.6
const CLUE_COUNT := 3

var player: CharacterBody3D
var exit_door: StaticBody3D
var ghost_node: Node3D
var task_label: Label
var message_label: Label
var prompt_label: Label
var interact_button: Button
var scare_overlay: ColorRect

var interactables: Array[Dictionary] = []
var house_lights: Array[OmniLight3D] = []
var clues_found: Dictionary = {}
var active_target_id := ""
var fuse_found := false
var power_restored := false
var key_revealed := false
var key_found := false
var exit_unlocked := false
var won := false
var ghost_timer := 0.0
var flicker_timer := 0.0
var message_version := 0

func _ready() -> void:
	randomize()
	_build_environment()
	_build_house()
	_build_player()
	_build_hud()
	_add_interactable("fuse", "TAKE THE SPARE FUSE", Vector3(-6.0, 0.95, 4.0), "fuse")
	_add_interactable("breaker", "RESTORE POWER AT THE FUSE BOX", Vector3(7.65, 1.55, 4.0), "breaker")
	_add_interactable("diary", "READ THE DIARY PAGE", Vector3(-6.0, 0.95, -4.8), "diary")
	_add_interactable("photo", "EXAMINE THE FAMILY PHOTOGRAPH", Vector3(6.8, 1.55, -4.8), "photo")
	_add_interactable("recording", "PLAY THE OLD RECORDING", Vector3(0.0, 0.9, -5.7), "recording")
	_update_objectives()
	_show_message("DISPATCH: Unit 12, confirm the disturbance at 14 Blackwood Lane.", 6.0)

func _process(delta: float) -> void:
	if won:
		return
	_update_interaction_prompt()
	if ghost_timer > 0.0:
		ghost_timer -= delta
		if ghost_timer <= 0.0 and is_instance_valid(ghost_node):
			ghost_node.visible = false
	if power_restored:
		flicker_timer -= delta
		if flicker_timer <= 0.0:
			for light in house_lights:
				if is_instance_valid(light):
					light.light_energy = randf_range(0.48, 0.78)
			flicker_timer = randf_range(0.08, 0.42)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_try_interact()

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#05080d")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#526174")
	env.ambient_light_energy = 0.13
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("#18212b")
	env.fog_density = 0.025
	env.glow_enabled = true
	env.glow_intensity = 0.35
	env.glow_bloom = 0.06
	world.environment = env
	add_child(world)

	var moon := DirectionalLight3D.new()
	moon.name = "Cold moonlight"
	moon.rotation_degrees = Vector3(-58.0, -28.0, 0.0)
	moon.light_color = Color("#8294aa")
	moon.light_energy = 0.12
	moon.shadow_enabled = true
	add_child(moon)

func _build_house() -> void:
	_add_box("Old wooden floor", Vector3(0, -0.25, 0), Vector3(18, 0.5, 18), Color("#24272b"))
	_add_box("Ceiling", Vector3(0, 3.45, 0), Vector3(18, 0.25, 18), Color("#10151c"))
	_add_box("West wall", Vector3(-9, 1.55, 0), Vector3(0.3, 3.1, 18), Color("#303038"))
	_add_box("East wall", Vector3(9, 1.55, 0), Vector3(0.3, 3.1, 18), Color("#303038"))
	_add_box("Front wall", Vector3(0, 1.55, 9), Vector3(18, 3.1, 0.3), Color("#303038"))
	_add_box("Back wall left", Vector3(-5.7, 1.55, -9), Vector3(6.6, 3.1, 0.3), Color("#303038"))
	_add_box("Back wall right", Vector3(5.7, 1.55, -9), Vector3(6.6, 3.1, 0.3), Color("#303038"))

	_add_box("Hall runner", Vector3(0, 0.012, 0), Vector3(2.2, 0.025, 14), Color("#33272a"), false)
	_add_box("Left room rug", Vector3(-5.2, 0.015, 0), Vector3(4.2, 0.03, 4.5), Color("#29252b"), false)
	_add_box("Right room rug", Vector3(5.2, 0.015, 0), Vector3(4.2, 0.03, 4.5), Color("#28272b"), false)

	# Furniture and environmental silhouettes.
	_add_table("Utility table", Vector3(-6.0, 0.0, 4.0), Vector3(1.8, 0.9, 1.15), Color("#40332d"))
	_add_box("Fuse cabinet", Vector3(8.55, 1.55, 4.0), Vector3(0.18, 1.35, 1.0), Color("#37383a"), false)
	_add_table("Writing desk", Vector3(-6.0, 0.0, -4.8), Vector3(1.9, 0.85, 1.0), Color("#382e2b"))
	_add_box("Display cabinet", Vector3(7.4, 1.05, -4.8), Vector3(1.0, 2.1, 1.0), Color("#30282a"))
	_add_table("Music table", Vector3(0.0, 0.0, -5.7), Vector3(1.5, 0.75, 1.0), Color("#46352d"))
	_add_box("Old sofa", Vector3(-4.6, 0.55, 0.8), Vector3(2.8, 1.1, 1.1), Color("#39343a"))
	_add_box("Side cabinet", Vector3(4.7, 0.65, 2.8), Vector3(1.0, 1.3, 0.9), Color("#39302d"))
	_add_box("Broken beam", Vector3(3.2, 2.9, -1.3), Vector3(5.8, 0.18, 0.2), Color("#25252a"), false)

	# Door frame and the locked front door.
	_add_box("Exit frame top", Vector3(0, 3.0, -8.9), Vector3(2.7, 0.2, 0.25), Color("#66513f"))
	_add_box("Exit frame left", Vector3(-1.25, 1.5, -8.9), Vector3(0.2, 3.0, 0.25), Color("#66513f"))
	_add_box("Exit frame right", Vector3(1.25, 1.5, -8.9), Vector3(0.2, 3.0, 0.25), Color("#66513f"))
	exit_door = _add_box("Locked front door", Vector3(0, 1.5, -8.82), Vector3(2.25, 2.9, 0.22), Color("#382b2a"))
	_add_box("Brass door handle", Vector3(0.82, 1.45, -8.68), Vector3(0.08, 0.28, 0.08), Color("#b99a62"), false)

	# Cold, weak ceiling lamps remain dark until the fuse box is repaired.
	_add_house_light(Vector3(-5.0, 2.75, 0.0), Color("#c4d1e2"), 0.0, 7.0)
	_add_house_light(Vector3(5.0, 2.75, 0.0), Color("#c4d1e2"), 0.0, 7.0)
	_add_house_light(Vector3(0.0, 2.75, -6.5), Color("#c4d1e2"), 0.0, 6.0)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "PoliceOfficer"
	player.position = Vector3(0, 0.02, 7.0)
	player.set_script(load("res://scripts/player.gd"))
	add_child(player)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "GameHUD"
	add_child(layer)

	var panel := ColorRect.new()
	panel.color = Color(0.015, 0.02, 0.03, 0.78)
	panel.position = Vector2(18, 18)
	panel.size = Vector2(405, 150)
	layer.add_child(panel)

	task_label = Label.new()
	task_label.position = Vector2(34, 28)
	task_label.size = Vector2(375, 132)
	task_label.add_theme_color_override("font_color", Color("#e2e5e8"))
	task_label.add_theme_font_size_override("font_size", 17)
	task_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	task_label.add_theme_constant_override("shadow_offset_x", 1)
	task_label.add_theme_constant_override("shadow_offset_y", 1)
	layer.add_child(task_label)

	var radio := Label.new()
	radio.anchor_left = 0.62
	radio.anchor_right = 0.98
	radio.anchor_top = 0.035
	radio.anchor_bottom = 0.10
	radio.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	radio.text = "POLICE RADIO  •  NO SIGNAL"
	radio.add_theme_color_override("font_color", Color("#b9c5d0"))
	radio.add_theme_font_size_override("font_size", 15)
	layer.add_child(radio)

	prompt_label = Label.new()
	prompt_label.anchor_left = 0.25
	prompt_label.anchor_right = 0.75
	prompt_label.anchor_top = 0.70
	prompt_label.anchor_bottom = 0.77
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_color_override("font_color", Color("#e7d7b0"))
	prompt_label.add_theme_font_size_override("font_size", 19)
	layer.add_child(prompt_label)

	message_label = Label.new()
	message_label.anchor_left = 0.13
	message_label.anchor_right = 0.87
	message_label.anchor_top = 0.80
	message_label.anchor_bottom = 0.96
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_color_override("font_color", Color("#f1eee8"))
	message_label.add_theme_font_size_override("font_size", 21)
	layer.add_child(message_label)

	var hint := Label.new()
	hint.anchor_left = 0.32
	hint.anchor_right = 0.68
	hint.anchor_top = 0.025
	hint.anchor_bottom = 0.075
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.text = "LEFT: MOVE     •     RIGHT: LOOK"
	hint.add_theme_color_override("font_color", Color("#aeb9c7"))
	hint.add_theme_font_size_override("font_size", 13)
	layer.add_child(hint)

	_add_touch_button(layer, "▲", Vector2(105, -190), "forward")
	_add_touch_button(layer, "▼", Vector2(105, -70), "back")
	_add_touch_button(layer, "◀", Vector2(45, -130), "left")
	_add_touch_button(layer, "▶", Vector2(165, -130), "right")

	interact_button = Button.new()
	interact_button.text = "INTERACT"
	interact_button.size = Vector2(142, 58)
	interact_button.anchor_left = 1.0
	interact_button.anchor_right = 1.0
	interact_button.anchor_top = 1.0
	interact_button.anchor_bottom = 1.0
	interact_button.offset_left = -178
	interact_button.offset_right = -28
	interact_button.offset_top = -92
	interact_button.offset_bottom = -28
	interact_button.add_theme_font_size_override("font_size", 18)
	interact_button.visible = false
	interact_button.pressed.connect(_try_interact)
	layer.add_child(interact_button)

	scare_overlay = ColorRect.new()
	scare_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scare_overlay.color = Color(0.45, 0.015, 0.025, 0.0)
	scare_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(scare_overlay)

func _add_touch_button(layer: CanvasLayer, label_text: String, offset: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = label_text
	button.size = Vector2(58, 58)
	button.anchor_left = 0.0
	button.anchor_right = 0.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = offset.x
	button.offset_right = offset.x + 58
	button.offset_top = offset.y
	button.offset_bottom = offset.y + 58
	button.modulate = Color(0.82, 0.88, 0.95, 0.86)
	button.add_theme_font_size_override("font_size", 24)
	button.button_down.connect(Callable(player, "set_touch_action").bind(action, true))
	button.button_up.connect(Callable(player, "set_touch_action").bind(action, false))
	layer.add_child(button)

func _add_table(table_name: String, position_value: Vector3, size_value: Vector3, color: Color) -> void:
	var top_size := Vector3(size_value.x, 0.14, size_value.z)
	_add_box(table_name + " top", position_value + Vector3(0, size_value.y, 0), top_size, color)
	var leg_size := Vector3(0.14, size_value.y, 0.14)
	var x_offset := size_value.x * 0.42
	var z_offset := size_value.z * 0.38
	for x in [-x_offset, x_offset]:
		for z in [-z_offset, z_offset]:
			_add_box(table_name + " leg", position_value + Vector3(x, size_value.y * 0.5, z), leg_size, color)

func _add_house_light(position_value: Vector3, tint: Color, energy: float, reach: float) -> void:
	var light := OmniLight3D.new()
	light.position = position_value
	light.light_color = tint
	light.light_energy = energy
	light.omni_range = reach
	light.shadow_enabled = false
	add_child(light)
	house_lights.append(light)

func _add_interactable(id: String, prompt: String, position_value: Vector3, kind: String) -> void:
	var root := Node3D.new()
	root.name = id.capitalize() + "Interactable"
	root.position = position_value
	var item := MeshInstance3D.new()
	var mesh_material := StandardMaterial3D.new()
	mesh_material.roughness = 0.42

	match kind:
		"fuse":
			var fuse_mesh := CylinderMesh.new()
			fuse_mesh.top_radius = 0.075
			fuse_mesh.bottom_radius = 0.075
			fuse_mesh.height = 0.48
			item.mesh = fuse_mesh
			mesh_material.albedo_color = Color("#d7b76a")
			mesh_material.metallic = 0.75
			mesh_material.emission_enabled = true
			mesh_material.emission = Color("#60451c")
		"breaker":
			var panel_mesh := BoxMesh.new()
			panel_mesh.size = Vector3(0.65, 0.82, 0.16)
			item.mesh = panel_mesh
			mesh_material.albedo_color = Color("#687078")
		"diary":
			var book_mesh := BoxMesh.new()
			book_mesh.size = Vector3(0.54, 0.12, 0.42)
			item.mesh = book_mesh
			mesh_material.albedo_color = Color("#5a302b")
		"photo":
			var frame_mesh := BoxMesh.new()
			frame_mesh.size = Vector3(0.58, 0.52, 0.09)
			item.mesh = frame_mesh
			mesh_material.albedo_color = Color("#b69a69")
			mesh_material.metallic = 0.2
		"recording":
			var tape_mesh := BoxMesh.new()
			tape_mesh.size = Vector3(0.48, 0.12, 0.34)
			item.mesh = tape_mesh
			mesh_material.albedo_color = Color("#3e454c")
		"key":
			var key_mesh := TorusMesh.new()
			key_mesh.inner_radius = 0.10
			key_mesh.outer_radius = 0.18
			item.mesh = key_mesh
			mesh_material.albedo_color = Color("#e0bf70")
			mesh_material.metallic = 0.85
			mesh_material.emission_enabled = true
			mesh_material.emission = Color("#8c6020")
	item.material_override = mesh_material
	root.add_child(item)

	var glow := OmniLight3D.new()
	glow.light_color = Color("#d8bd82") if kind == "key" or kind == "fuse" else Color("#7b9ab5")
	glow.light_energy = 0.22 if kind == "key" or kind == "fuse" else 0.08
	glow.omni_range = 2.1
	root.add_child(glow)
	add_child(root)
	interactables.append({"id": id, "prompt": prompt, "node": root, "used": false})

func _update_interaction_prompt() -> void:
	active_target_id = ""
	var best_distance := INTERACT_DISTANCE
	var best_prompt := ""
	for entry in interactables:
		if entry["used"]:
			continue
		var node: Node3D = entry["node"]
		if not is_instance_valid(node):
			continue
		var distance := player.global_position.distance_to(node.global_position)
		if distance < best_distance:
			best_distance = distance
			active_target_id = entry["id"]
			best_prompt = entry["prompt"]
	if active_target_id == "":
		prompt_label.text = ""
		interact_button.visible = false
	else:
		prompt_label.text = best_prompt + "  [E]"
		interact_button.visible = true

func _try_interact() -> void:
	if active_target_id == "":
		return
	match active_target_id:
		"fuse":
			fuse_found = true
			_mark_interactable_used("fuse")
			_show_message("SPARE FUSE FOUND. The fuse box is on the east wall.", 4.5)
		"breaker":
			if not fuse_found:
				_show_message("The fuse box is damaged. Find a spare fuse first.", 3.5)
				return
			power_restored = true
			_mark_interactable_used("breaker")
			for light in house_lights:
				light.light_energy = 0.72
			_show_message("POWER RESTORED. A shape just crossed the hallway.", 4.0)
			_trigger_ghost_scare()
		"diary":
			_collect_clue("diary")
		"photo":
			_collect_clue("photo")
		"recording":
			_collect_clue("recording")
		"key":
			key_found = true
			_mark_interactable_used("key")
			exit_unlocked = true
			if is_instance_valid(exit_door):
				exit_door.queue_free()
			_add_interactable("exit", "LEAVE THE HOUSE", Vector3(0.0, 1.0, -8.1), "breaker")
			_show_message("The key turns. The front door creaks open.", 4.0)
		"exit":
			if key_found:
				won = true
				interact_button.visible = false
				_show_message("CASE CLOSED. YOU MADE IT OUT.   •   THE LAST CALL", 999.0)
				player.set_physics_process(false)
	_update_objectives()

func _collect_clue(id: String) -> void:
	if clues_found.has(id):
		return
	clues_found[id] = true
	_mark_interactable_used(id)
	match id:
		"diary":
			_show_message("MIRA'S DIARY: “I promised Ma I would keep Arin safe. Even if this house is all we have left.”", 6.0)
		"photo":
			_show_message("FAMILY PHOTO: Mira and her younger brother Arin. On the back: “The two of us, always.”", 6.0)
		"recording":
			_show_message("FINAL RECORDING: “The storm started a fire in the old wiring. Arin got out. I went back to cut the power, but the smoke filled the hall and the front door jammed. Please tell him I kept my promise.”", 8.0)
			_trigger_ghost_scare()
	_update_objectives()
	if power_restored and clues_found.size() >= CLUE_COUNT:
		_reveal_key()

func _reveal_key() -> void:
	if key_revealed:
		return
	key_revealed = true
	_add_interactable("key", "TAKE THE FRONT DOOR KEY", Vector3(0.0, 1.0, -6.65), "key")
	_show_message("The music box clicks open. A brass key is inside.", 5.0)
	_trigger_ghost_scare()

func _mark_interactable_used(id: String) -> void:
	for index in range(interactables.size()):
		if interactables[index]["id"] == id:
			interactables[index]["used"] = true
			var node: Node3D = interactables[index]["node"]
			if is_instance_valid(node):
				node.queue_free()
			return

func _update_objectives() -> void:
	var fuse_status := "✓" if fuse_found else "□"
	var power_status := "✓" if power_restored else "□"
	var memory_status := "✓" if clues_found.size() >= CLUE_COUNT else "□"
	var key_status := "✓" if key_found else "□"
	task_label.text = "CASE 014  /  BLACKWOOD HOUSE\n"
	task_label.text += "%s  Find a spare fuse\n" % fuse_status
	task_label.text += "%s  Restore the house power\n" % power_status
	task_label.text += "%s  Recover Mira's memories (%d/3)\n" % [memory_status, clues_found.size()]
	task_label.text += "%s  Find the front-door key" % key_status

func _trigger_ghost_scare() -> void:
	if not is_instance_valid(player):
		return
	if is_instance_valid(ghost_node):
		ghost_node.queue_free()
	ghost_node = _make_ghost()
	add_child(ghost_node)
	var forward := -player.global_transform.basis.z
	ghost_node.global_position = player.global_position + forward * 3.0
	ghost_node.global_position.y = 0.0
	ghost_node.look_at(player.global_position + Vector3(0, 1.1, 0), Vector3.UP)
	ghost_node.visible = true
	ghost_timer = 1.8
	scare_overlay.color = Color(0.42, 0.015, 0.025, 0.0)
	var tween := create_tween()
	tween.tween_property(scare_overlay, "color", Color(0.42, 0.015, 0.025, 0.48), 0.06)
	tween.tween_property(scare_overlay, "color", Color(0.42, 0.015, 0.025, 0.0), 0.4)

func _show_message(value: String, duration: float) -> void:
	message_version += 1
	var this_message := message_version
	message_label.text = value
	if duration < 900.0:
		var timer := get_tree().create_timer(duration)
		timer.timeout.connect(func():
			if is_instance_valid(message_label) and this_message == message_version and not won:
				message_label.text = ""
		)

func _make_ghost() -> Node3D:
	var ghost := Node3D.new()
	ghost.name = "MiraApparition"

	var gown := MeshInstance3D.new()
	var gown_mesh := CapsuleMesh.new()
	gown_mesh.radius = 0.43
	gown_mesh.height = 1.8
	gown.mesh = gown_mesh
	gown.position.y = 1.0
	gown.material_override = _ghost_material(Color(0.72, 0.8, 0.88, 0.72))
	ghost.add_child(gown)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.31
	head_mesh.height = 0.62
	head.mesh = head_mesh
	head.position = Vector3(0, 2.08, 0)
	head.material_override = _ghost_material(Color(0.82, 0.85, 0.9, 0.8))
	ghost.add_child(head)

	var hair := MeshInstance3D.new()
	var hair_mesh := SphereMesh.new()
	hair_mesh.radius = 0.35
	hair_mesh.height = 0.68
	hair.mesh = hair_mesh
	hair.position = Vector3(0, 2.12, 0.075)
	hair.material_override = _ghost_material(Color(0.035, 0.045, 0.065, 0.95))
	ghost.add_child(hair)

	var hair_back := MeshInstance3D.new()
	var hair_back_mesh := CapsuleMesh.new()
	hair_back_mesh.radius = 0.12
	hair_back_mesh.height = 1.05
	hair_back.mesh = hair_back_mesh
	hair_back.position = Vector3(0, 1.75, 0.28)
	hair_back.material_override = _ghost_material(Color(0.025, 0.03, 0.045, 0.95))
	ghost.add_child(hair_back)

	for side in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var arm_mesh := CapsuleMesh.new()
		arm_mesh.radius = 0.10
		arm_mesh.height = 0.95
		arm.mesh = arm_mesh
		arm.position = Vector3(side * 0.47, 1.25, 0.0)
		arm.rotation.z = side * -0.28
		arm.material_override = _ghost_material(Color(0.7, 0.78, 0.88, 0.62))
		ghost.add_child(arm)
	return ghost

func _ghost_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = Color(color.r * 0.42, color.g * 0.5, color.b * 0.65, 1.0)
	return material

func _add_box(label: String, position_value: Vector3, size_value: Vector3, color: Color, collision := true) -> StaticBody3D:
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
	return body

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material
