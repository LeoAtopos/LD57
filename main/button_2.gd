extends Button

var shake_intensity: float = 2.0
var original_position: Vector2

func _ready() -> void:
	original_position = position

func _process(delta: float) -> void:
	# Continuous random offset within intensity range
	position.x = original_position.x + randf_range(- shake_intensity, shake_intensity)
	position.y = original_position.y + randf_range(- shake_intensity, shake_intensity)
