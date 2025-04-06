extends Control

signal drag_started
signal drag_ended

var dragging := false
var drag_offset := Vector2.ZERO

func _ready() -> void:
	# Set up input handling
	mouse_filter = MOUSE_FILTER_STOP
	z_index = 10
	show_behind_parent = false
	
	# Connect gui_input signal
	gui_input.disconnect(_on_gui_input) # Ensure clean state
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event)
			else:
				_end_drag(event)

func _start_drag(event: InputEvent):
	dragging = true
	drag_offset = get_global_mouse_position() - global_position
	emit_signal("drag_started", self)
	
	# Move to top of parent's children
	if get_parent():
		get_parent().move_child(self, get_parent().get_child_count())

func _end_drag(event: InputEvent):
	dragging = false
	emit_signal("drag_ended", self)
	# Ensure we stay interactive after drop
	mouse_filter = MOUSE_FILTER_STOP

func _process(delta: float):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset
		# Fallback check for mouse release that wasn't detected by gui_input
		if dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_end_drag(null)
