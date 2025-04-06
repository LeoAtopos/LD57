extends Node2D

@export var state_chart: StateChart
@export var openning_stuff: Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	openning_stuff.modulate.a = 0 # Start hidden
	await get_tree().create_timer(0.3).timeout # Wait 0.3s
	
	# Create fade-in tween over 0.5s
	var tween = create_tween()
	tween.tween_property(openning_stuff, "modulate:a", 1.0, 0.5)

func _on_monolog_state_entered() -> void:
	print("in dialog")
	openning_stuff.queue_free()
	Dialogic.start("entry_line")
	Dialogic.connect("signal_event", _on_dialogic_signal)

func _on_dialogic_signal(massage:String):
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://main/test_scene.tscn")


func _on_openning_state_processing(delta: float) -> void:
	if openning_stuff:
		if openning_stuff.modulate.a >= 1.0 and Input.is_action_just_pressed("dialogic_default_action"):
			state_chart.send_event("start")
