class_name EnvironmentSpawner extends Node3D

@onready var base_ground_scene := preload("res://Components/SpawnableEntities/BaseGround.tscn")
@onready var overhang_platform_scene := preload("res://Components/SpawnableEntities/OverhangPlatform.tscn")
@onready var long_hanging_platform_scene := preload("res://Components/SpawnableEntities/LongHangingPlatform.tscn")

@onready var eel_scene := preload("res://Components/Mobs/Eel/Eel.tscn")

@onready var kelp_scene := preload("res://Components/Decoration/Kelp.tscn")

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
		handle_kelp_spawn()
		handle_spawn_eels()
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

var kelp_spawn_timer := 0.0
var kelp_spawn_interval := 0.25

func handle_kelp_spawn():
	var now = Time.get_unix_time_from_system()
	if now - kelp_spawn_timer >= kelp_spawn_interval:
		spawn_kelp(-32.0, 180.0)
		spawn_kelp(32.0, 0.0)
		kelp_spawn_timer = now

func spawn_kelp(x_position : float, rotation_in_degrees : float):
	var kelp_scene_instance = kelp_scene.instantiate() as Kelp
	kelp_scene_instance.environment_spawner = self
	add_child(kelp_scene_instance)
	kelp_scene_instance.global_position.x = x_position
	kelp_scene_instance.global_position.y = -45.0 + randf_range(0.025, 0.5)
	kelp_scene_instance.global_position.z = randf_range(-17.0, 5.0)
	kelp_scene_instance.rotation.y = deg_to_rad(rotation_in_degrees)

var eel_spawn_timer := 0.0
var eel_spawn_interval := 25.0

func handle_spawn_eels():
	var now = Time.get_unix_time_from_system()
	if distance_traveled >= 50.0 && distance_traveled <= 180.0:
		if now - eel_spawn_timer >= eel_spawn_interval:
			spawn_eel()
			eel_spawn_timer = now

func spawn_eel():
	eel_spawn_interval = randf_range(25.0, 30.0)
	var eel_scene_instance = eel_scene.instantiate() as Eel
	eel_scene_instance.environment_spawner = self
	add_child(eel_scene_instance)
	eel_scene_instance.global_position.y = -25.0
	eel_scene_instance.rotate_y(deg_to_rad(180))

func handle_spawning():
	var now = Time.get_unix_time_from_system()
	if distance_traveled <= 170:
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
	if distance_traveled <= 195:
		var t = clamp(distance_traveled / MIDDLE_DISTANCE, 0.0, 2.0)
		t = 1.0 - abs(t - 1.0)  # This mirrors the lerp effect
		world_environment.environment.volumetric_fog_density = lerp(BASE_VOLUMETRIC_FOG_DENSITY, MAX_VOLUMETRIC_FOG_DENSITY, t)
		world_environment.environment.background_energy_multiplier = lerp(BASE_ENERGY_MULTIPLIER, MIN_ENERGY_MULTIPLIER, t)
	else:
		world_environment.environment.background_energy_multiplier += 5.0 * _delta
	
