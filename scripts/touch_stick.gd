extends Control

signal vector_changed(value: Vector2)

var finger_id := -1
var axis := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and finger_id == -1:
			finger_id = event.index
			_update_axis(event.position)
		elif not event.pressed and event.index == finger_id:
			finger_id = -1
			_set_axis(Vector2.ZERO)
	elif event is InputEventScreenDrag and event.index == finger_id:
		_update_axis(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			finger_id = 0
			_update_axis(event.position)
		else:
			finger_id = -1
			_set_axis(Vector2.ZERO)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_axis(event.position)

func _update_axis(position: Vector2) -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.34
	if radius <= 1.0:
		return
	var value := (position - center) / radius
	if value.length() > 1.0:
		value = value.normalized()
	_set_axis(value)

func _set_axis(value: Vector2) -> void:
	axis = value
	vector_changed.emit(axis)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.34
	draw_circle(center, radius * 1.28, Color(0.04, 0.07, 0.06, 0.42))
	draw_arc(center, radius * 1.28, 0.0, TAU, 64, Color(0.83, 0.88, 0.78, 0.58), 3.0, true)
	draw_circle(center + axis * radius, radius * 0.48, Color(0.88, 0.91, 0.82, 0.88))
	draw_arc(center + axis * radius, radius * 0.48, 0.0, TAU, 48, Color(0.18, 0.25, 0.18, 0.9), 2.0, true)
