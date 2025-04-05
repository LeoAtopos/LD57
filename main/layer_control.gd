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
	
	# Debug print parent chain
	print("=== Parent Chain Debug ===")
	var parent = get_parent()
	while parent:
		print("Parent: ", parent.name, " (", parent.get_class(), ")")
		if parent.has_method("get_mouse_filter"):
			print("- Mouse filter: ", parent.mouse_filter)
		parent = parent.get_parent()
	print("========================")
	
	# Connect gui_input signal
	gui_input.disconnect(_on_gui_input) # Ensure clean state
	var connect_result = gui_input.connect(_on_gui_input)
	print("GUI input connection result: ", connect_result)

func _on_gui_input(event: InputEvent):
	print("GUI Input Event: ", event)
	if event is InputEventMouseButton:
		print("Mouse button: ", event.button_index, " pressed: ", event.pressed)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("---- DRAG START ----")
				_start_drag(event)
			else:
				print("---- DRAG END ----")
				print("Event position: ", event.position, " global: ", get_global_mouse_position())
				print("Dragging state before: ", dragging)
				_end_drag(event)
				print("Dragging state after: ", dragging)

func _start_drag(event: InputEvent):
	dragging = true
	drag_offset = get_global_mouse_position() - global_position
	emit_signal("drag_started", self)
	
	# Move to top of parent's children
	if get_parent():
		get_parent().move_child(self, get_parent().get_child_count())

func _end_drag(event: InputEvent):
	print("Drag ended at position: ", get_global_mouse_position())
	dragging = false
	emit_signal("drag_ended", self)
	# Ensure we stay interactive after drop
	mouse_filter = MOUSE_FILTER_STOP

func _process(delta: float):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset
		# Fallback check for mouse release that wasn't detected by gui_input
		if dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			print("Fallback detected mouse release")
			_end_drag(null)
