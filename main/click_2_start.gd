extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0
	var breath_speed = 1.7 # Speed of breathing effect
	var min_alpha = 0.35 # Minimum alpha value
	var max_alpha = 1.0 # Maximum alpha value
	
	# Calculate alpha using sine wave for smooth oscillation
	var alpha = min_alpha + (max_alpha - min_alpha) * (sin(time * breath_speed) + 1) / 2
	self.modulate.a = alpha
