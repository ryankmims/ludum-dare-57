class_name EnvironmentSpawner extends Node3D

@onready var base_ground_scene := preload("res://Components/SpawnableEntities/BaseGround.tscn")

const FLOAT_SPEED := 1.5

const MAX_SPAWN_X := 30.0
const MIN_SPAWN_X := -30.0

var is_falling := true
var should_spawn := true

var spawn_timer := 0.0
var spawn_interval := 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer = Time.get_unix_time_from_system()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_falling:
		handle_spawning()

func handle_spawning():
	var now = Time.get_unix_time_from_system()
	if should_spawn:
		var random_spawn_x = randf_range(MIN_SPAWN_X, MAX_SPAWN_X)
		var base_ground_instance = base_ground_scene.instantiate() as SpawnableEntity
		base_ground_instance.environment_spawner = self
		add_child(base_ground_instance)
		base_ground_instance.global_position = Vector3(random_spawn_x, -20.0, 0.0)
		spawn_timer = now
		should_spawn = false
	else:
		if (now - spawn_timer) >= spawn_interval:
			should_spawn = true
