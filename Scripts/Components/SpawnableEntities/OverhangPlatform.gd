class_name OverhangPlatform extends SpawnableEntity

@onready var spawn_location := $SpawnLocation
var random_number_generator : RandomNumberGenerator


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	var orientation = randi_range(0, 2)
	if orientation != 0:
		print_debug("should rotate platform")
		rotate_y(deg_to_rad(180.0))
	
	if environment_spawner.distance_traveled >= LEVEL_TO_START_SPAWNING:
		if environment_spawner.distance_traveled < environment_spawner.MIDDLE_DISTANCE:
			handle_spawns()

func handle_spawns():
	var roll = randi_range(0, 4)
	if roll == 0:
		var dag_scene_instance = dag_scene.instantiate() as Dag
		dag_scene_instance.spawnable_entity = self
		add_child(dag_scene_instance)
		dag_scene_instance.global_position = spawn_location.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
