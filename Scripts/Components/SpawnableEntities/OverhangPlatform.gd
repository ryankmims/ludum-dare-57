class_name OverhangPlatform extends SpawnableEntity

var random_number_generator : RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	var orientation = randi_range(0, 2)
	if orientation != 0:
		print_debug("should rotate platform")
		rotate_y(deg_to_rad(180.0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
