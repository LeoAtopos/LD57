extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start("ending0_line")
	Dialogic.connect("signal_event", handle_signal)


func handle_signal(m):
	get_tree().change_scene_to_file("res://main/entry_desk.tscn")
