extends Control

func _ready() -> void:
	_build_screen()

func _build_screen() -> void:
	var background := ColorRect.new()
	background.color = Color("#101820")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.custom_minimum_size = Vector2(420, 240)
	center.add_child(content)

	var title := Label.new()
	title.text = "DAY LONG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color("#F2F5EA"))
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Your Godot project is connected."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color("#A9B7B0"))
	content.add_child(subtitle)

	var status := Label.new()
	status.text = "STARTER SCREEN • ANDROID-FRIENDLY BASE"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 13)
	status.add_theme_color_override("font_color", Color("#8BD3C7"))
	content.add_child(status)
