class_name EnvironmentSpawner extends Node3D

@onready var base_ground_scene := preload("res://Components/SpawnableEntities/BaseGround.tscn")
@onready var overhang_platform_scene := preload("res://Components/SpawnableEntities/OverhangPlatform.tscn")
@onready var long_hanging_platform_scene := preload("res://Components/SpawnableEntities/LongHangingPlatform.tscn")

@onready var particles := $"../Particles"

@export var float_speed := 1.5

@export var world_environment : WorldEnvironment
@export var player : Player

const BASE_FLOAT_SPEED := 1.5
const SPEED_UP_MODIFIER := 2.0
const SPEED_DOWN_MODIFIER := 0.5

const BASE_VOLUMETRIC_FOG_DENSITY := 0.0359
const MAX_VOLUMETRIC_FOG_DENSITY := 0.4006

const BASE_ENERGY_MULTIPLIER := 2.0
const MIN_ENERGY_MULTIPLIER := 0.25

const MAX_SPAWN_X := 30.0
const MIN_SPAWN_X := -30.0

const MIDDLE_DISTANCE := 100.0

var is_falling := true
var should_spawn := true

var spawn_timer := 0.0
var spawn_interval := 5.0

var distance_traveled := 0.0
var particles_flipped := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer = Time.get_unix_time_from_system()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_world_environment(delta)
	
	if distance_traveled >= MIDDLE_DISTANCE && !particles_flipped:
		flip_particles()
		particles_flipped = true
	
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

func flip_particles():
	for particle_effect in particles.get_children():
		if particle_effect is GPUParticles3D:
			particle_effect.process_material.gravity.y = -particle_effect.process_material.gravity.y
			particle_effect.global_position.y = -particle_effect.global_position.y - 5.0

func handle_spawning():
	var now = Time.get_unix_time_from_system()
	if should_spawn:
		var random_spawn_x = randf_range(MIN_SPAWN_X, MAX_SPAWN_X)
		var ground_spawn
		var roll = randi_range(0, 4)
		#var roll = 0
		match roll:
			0:
				ground_spawn = base_ground_scene.instantiate() as SpawnableEntity
			1:
				ground_spawn = overhang_platform_scene.instantiate() as SpawnableEntity
			2:
				ground_spawn = long_hanging_platform_scene.instantiate() as SpawnableEntity
			_:
				ground_spawn = base_ground_scene.instantiate() as SpawnableEntity
		ground_spawn.environment_spawner = self
		ground_spawn.player = player
		add_child(ground_spawn)
		ground_spawn.global_position = Vector3(random_spawn_x, -20.0, 0.0)
		if distance_traveled >= MIDDLE_DISTANCE:
			ground_spawn.rotate_x(deg_to_rad(180.0))
		spawn_timer = now
		should_spawn = false
	else:
		if (now - spawn_timer) >= spawn_interval:
			should_spawn = true

func handle_world_environment(_delta : float) -> void:
	var t = clamp(distance_traveled / MIDDLE_DISTANCE, 0.0, 2.0)
	t = 1.0 - abs(t - 1.0)  # This mirrors the lerp effect
	world_environment.environment.volumetric_fog_density = lerp(BASE_VOLUMETRIC_FOG_DENSITY, MAX_VOLUMETRIC_FOG_DENSITY, t)
	world_environment.environment.background_energy_multiplier = lerp(BASE_ENERGY_MULTIPLIER, MIN_ENERGY_MULTIPLIER, t)
