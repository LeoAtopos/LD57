extends Node2D

@export var back_pic1 : TextureRect
@export var back_pic2 : TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_pic1.show()
	back_pic2.hide()
	Dialogic.start("ending3_line")
	Dialogic.connect("signal_event", handle_signal)


func handle_signal(m):
	if m == "ending3 cut":
		back_pic2.show()
	if m == "replay":
		get_tree().change_scene_to_file("res://main/entry_desk.tscn")
