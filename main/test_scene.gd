extends Node2D

@export var pic_tree: Node2D
@export var layer_tree: Control # Changed from VBoxContainer to generic Control
@export var ui: CanvasLayer
@export var state_chart: StateChart
@export var cva_ref: Sprite2D
@export var done_button :Button
@export var see_button : Button
@export var layer_chart : MarginContainer
@export var clip_panel : Control

var pics_array = []
var layer_array = []
# Called when the node enters the scene tree for the first time.
var dragged_label_parent = null
var dragged_label_index = -1

var drop_time := 0

var playing_stage := 1

func _on_label_drag_started(label):
	dragged_label_parent = label.get_parent()
	dragged_label_index = label.get_index()
	dragged_label_parent.remove_child(label)
	ui.add_child(label)
	label.z_index = 10 # Ensure it appears above other elements

func _on_label_drag_ended(label):
	drop_time += 1
	# Remove from current parent (ui layer)
	if label.is_inside_tree() and label.get_parent() == ui:
		ui.remove_child(label)
	
	# Add back to layer tree
	layer_tree.add_child(label)
	
	# Calculate drop position relative to layer_tree
	var local_pos = layer_tree.get_global_transform().affine_inverse() * label.global_position
	var drop_pos = local_pos.y
	var insert_index = 0
	
	# Find insert position accounting for label height
	for i in range(layer_tree.get_child_count()):
		var child = layer_tree.get_child(i)
		var child_pos = child.global_position.y
		var child_height = child.size.y if child.has_method("get_size") else 0
		# Check if drop position is above child's midpoint
		if drop_pos < child_pos + child_height / 2:
			insert_index = i
			#print("drop_pos:", drop_pos, " child_pos:", child_pos, " child_height:", child_height)
			break
		else:
			insert_index = i + 1
	
	# Ensure valid index
	insert_index = clamp(insert_index, 0, layer_tree.get_child_count() - 1)
	
	print("Insert index: ", insert_index)
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
	
	var order_dic:= {}
	var i = 1
	for c in pic_tree.get_children():
		order_dic[c.texture.resource_path.get_file()] = i
		i += 1
	print(order_dic)
	if playing_stage == 1:
		if check_if_order_good(order_dic):
			print("order good!!!!!")
			done_button.show()
			if drop_time == 4 or drop_time == 14:
				Dialogic.start("easy_give_up_line")
		else:
			done_button.hide()
	
	if check_show_help(order_dic):
		print("help!!!!")
		see_button.show()
	else:
		print(".....")
		see_button.show()
	if playing_stage == 2:
		done_button.show()
		

func check_if_order_good(order:Dictionary):
	if order['blue sky.png'] == 1:
		if order['bank grass.png'] == 2:
			if order['clouds.png'] == 3:
				if order['far tower.png'] == 4:
					if order['river.png'] == 5:
						if order['bridge.png'] == 6:
							if order['mountain.png'] == 7:
								if order['factory.png'] == 8:
									if order['trees.png'] == 9:
										if order['ufo far.png'] > order['trees.png']:
											if order['ufo behind cat.png'] > order['clouds.png'] and order['ufo behind cat.png'] < order['cat.png']:
												if order['cat.png'] < order['logo.png'] and order['cat.png'] > order['mountain.png']:
													if order['logo.png'] > order['cat.png']:
														return true
	return false

func check_show_help(order:Dictionary):
	if order['blue sky.png'] < order['mountain.png'] and order['blue sky.png'] < order['bridge.png']:
		if order['clouds.png'] > order['bridge.png']:
			if order['far tower.png'] > order['mountain.png'] and order['far tower.png'] < order['clouds.png'] and order['far tower.png'] < order['bank grass.png']:
				if order['factory.png'] > order['trees.png'] and order['ufo far.png'] < order['mountain.png']:
					if order['cat.png'] > order['bank grass.png'] and order['cat.png'] < order['ufo behind cat.png']:
						return true
	return false

func _ready() -> void:
	pics_array = pic_tree.get_children()
	layer_array = layer_tree.get_children()
	done_button.hide()
	see_button.hide()
	clip_panel.hide()
	# Set label text to matching pic's texture resource name
	for label in layer_array:
		for pic in pics_array:
			if pic.name == label.name:
				if pic is Sprite2D and pic.texture != null:
					label.text = pic.texture.resource_path.get_file()
				break
	
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


func _on_beginning_state_entered() -> void:
	ui.hide()
	pic_tree.position = Vector2(0, 0)
	Dialogic.start("begin_line")
	Dialogic.connect("signal_event", _handle_dialog_done)

func _handle_dialog_done(massage):
	if massage == "begin done":
		pic_tree.position = Vector2(-74, 0)
		ui.show()
		Dialogic.start("begine_line_2")
	if massage == "go play":
		state_chart.send_event("play")
	if massage == "submit":
		get_tree().change_scene_to_file("res://main/ending1.tscn")
	if massage == "go on":
		state_chart.send_event("play2")
	if massage == "want give up":
		get_tree().change_scene_to_file("res://main/ending1.tscn")
	if massage == "mail ask":
		get_tree().change_scene_to_file("res://main/ending2.tscn")
	if massage == "report up":
		get_tree().change_scene_to_file("res://main/ending3.tscn")
	if massage == "call 911":
		get_tree().change_scene_to_file("res://main/ending4.tscn")


func _on_button_pressed() -> void:
	if playing_stage == 1:
		Dialogic.start("Done_sorting_line")
	if playing_stage == 2:
		Dialogic.start("Done_2_line")


func _on_playing_state_entered() -> void:
	playing_stage = 1


func _on_playing_2_state_entered() -> void:
	playing_stage = 2


func _on_button_2_pressed() -> void:
	state_chart.send_event("saw help")


func _on_found_state_entered() -> void:
	layer_chart.hide()
	see_button.hide()
	done_button.hide()
	pic_tree.position = Vector2(0,0)
	clip_panel.show()
	Dialogic.start("saw_help_line")
	
	
