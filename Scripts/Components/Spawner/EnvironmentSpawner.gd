class_name EnvironmentSpawner extends Node3D

@onready var base_ground_scene := preload("res://Components/SpawnableEntities/BaseGround.tscn")
@onready var overhang_platform_scene := preload("res://Components/SpawnableEntities/OverhangPlatform.tscn")

@export var float_speed := 1.5

const BASE_FLOAT_SPEED := 1.5
const SPEED_UP_MODIFIER := 2.0
const SPEED_DOWN_MODIFIER := 0.5

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
		if get_parent().get_node("Player").anchor.is_grabbed:
			if Input.is_action_pressed("move_up"):
				float_speed = BASE_FLOAT_SPEED * SPEED_DOWN_MODIFIER
			elif Input.is_action_pressed("move_down"):
				float_speed = BASE_FLOAT_SPEED * SPEED_UP_MODIFIER
			else:
				float_speed = BASE_FLOAT_SPEED
		else:
			float_speed = BASE_FLOAT_SPEED

func handle_spawning():
	var now = Time.get_unix_time_from_system()
	if should_spawn:
		var random_spawn_x = randf_range(MIN_SPAWN_X, MAX_SPAWN_X)
		var base_ground_instance = overhang_platform_scene.instantiate() as SpawnableEntity
		base_ground_instance.environment_spawner = self
		add_child(base_ground_instance)
		base_ground_instance.global_position = Vector3(random_spawn_x, -20.0, 0.0)
		spawn_timer = now
		should_spawn = false
	else:
		if (now - spawn_timer) >= spawn_interval:
			should_spawn = true
