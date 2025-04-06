class_name BaseGround extends SpawnableEntity

@onready var spawn_location := $SpawnLocation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	var roll = randi_range(0, 5)
	if roll == 0:
		var dag_scene_instance = dag_scene.instantiate() as Dag
		dag_scene_instance.spawnable_entity = self
		add_child(dag_scene_instance)
		dag_scene_instance.global_position = spawn_location.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
