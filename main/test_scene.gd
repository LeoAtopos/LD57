extends Node2D

@export var pic_tree: Node2D
@export var layer_tree: Control # Changed from VBoxContainer to generic Control
@export var ui: CanvasLayer

var pics_array = []
var layer_array = []
# Called when the node enters the scene tree for the first time.
var dragged_label_parent = null
var dragged_label_index = -1

func _on_label_drag_started(label):
	dragged_label_parent = label.get_parent()
	dragged_label_index = label.get_index()
	dragged_label_parent.remove_child(label)
	ui.add_child(label)
	label.z_index = 10 # Ensure it appears above other elements

func _on_label_drag_ended(label):
	# Remove from current parent (ui layer)
	if label.is_inside_tree() and label.get_parent() == ui:
		ui.remove_child(label)
	
	# Add back to layer tree
	layer_tree.add_child(label)
	
	# Calculate drop position
	var drop_pos = label.global_position.y
	var insert_index = 0
	for i in range(layer_tree.get_child_count()):
		var child = layer_tree.get_child(i)
		if drop_pos < child.global_position.y:
			insert_index = i
			break
		else:
			insert_index = i + 1
	
	# Ensure valid index
	insert_index = clamp(insert_index, 0, layer_tree.get_child_count() - 1)
	
	# Reorder child
	layer_tree.move_child(label, insert_index)
	
	# Reorder pic_tree to maintain reverse of layer order
	var new_pic_order = []
	# Get layer labels in current order
	var layer_labels = layer_tree.get_children()
	# Iterate in reverse to match original pic order
	for j in range(layer_labels.size() - 1, -1, -1):
		for pic in pics_array:
			if pic.name == layer_labels[j].name:
				new_pic_order.append(pic)
				break
	
	if new_pic_order.size() == pics_array.size():
		for i in new_pic_order.size():
			pic_tree.move_child(new_pic_order[i], i)
	else:
		pass

func _ready() -> void:
	randomize()
	pics_array = pic_tree.get_children()
	pics_array.shuffle()
	for i in pics_array.size():
		pic_tree.move_child(pics_array[i], i)
		
	layer_array = layer_tree.get_children()
	
	# Generate random text for each label
	for label in layer_array:
		var random_text = ""
		for i in randi_range(5, 10): # 5-10 random characters
			random_text += char(randi_range(33, 126)) # Printable ASCII chars
		label.text = random_text
	
	# Ensure all parents ignore mouse events
	var parent = layer_tree
	while parent:
		if parent.has_method("set_mouse_filter"):
			parent.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent = parent.get_parent()
	
	# Connect drag signals for all layer labels
	for label in layer_array:
		if label.has_signal("drag_started"):
			label.drag_started.connect(_on_label_drag_started)
		if label.has_signal("drag_ended"):
			label.drag_ended.connect(_on_label_drag_ended)

	# Reorder layer_array to match pics_array order by node name
	var new_layer_order = []
	for pic in pics_array:
		for label in layer_array:
			if label.name == pic.name:
				new_layer_order.append(label)
				break
	
	# Update layer_tree children order in reverse of pics_array
	if new_layer_order.size() == layer_array.size():
		for i in new_layer_order.size():
			# Place in reverse order (last pic becomes first label)
			layer_tree.move_child(new_layer_order[i], layer_array.size() - 1 - i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
