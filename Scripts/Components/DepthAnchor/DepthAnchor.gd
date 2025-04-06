class_name DepthAnchor extends Node3D

const ANCHOR_GRAVITY_BOUY_MODIFIER := 0.235
const SPEED = 0.069
const HALTED_SPEED_MODIFER := 0.25
const JUMP_VELOCITY = 4.5
const MAX_ROTATION := 0.3 
const ROTATION_LERP_SPEED := 5.0 

const ZOOM_OUT_FOV := 90.0
const NORMAL_FOV := 75.0

const MIN_ANCHOR_POSITION := -30.0
const MAX_ANCHOR_POSITION := 30.0

const DAMAGE_COOLDOWN := 0.5 

const DISTANCE_GAIN_RATE := 1.0  

@onready var dragging_sound := preload("res://Audio/SoundEffects/dragging_sound.wav")
@onready var impact_sound := preload("res://Audio/SoundEffects/impact_sound.wav")

@onready var camera := $Camera3D
@onready var anchor_mesh := $MeshAndStoppingAreaContainer/AnchorMesh
@onready var mesh_and_stopping_area_container := $MeshAndStoppingAreaContainer

@onready var audio_player := $AudioPlayer

@export var max_downward_velocity := 15.0
@export var camera_lerp_speed: float = 5.0

@export var environment_spawner : EnvironmentSpawner

var is_grabbed := false
var current_fov = NORMAL_FOV
var target_fov = NORMAL_FOV
var target_rotation := 0.0

var halt_rotation := false
var current_speed_modifier := 1.0

var damage_cooldown_timer := 0.0
var current_platform = null

var distance_traveled := 0.0

var anchor_is_dragging = false
var audio_playing = false
var has_played_impact = false

func _process(delta: float) -> void:
	environment_spawner.distance_traveled = distance_traveled
	handle_grab_camera(delta)
	handle_anchor_sounds()

func _physics_process(delta: float) -> void:
	if damage_cooldown_timer > 0:
		damage_cooldown_timer -= delta
	
	if is_grabbed:
		handle_movement(delta)
	else:
		target_rotation = 0.0
	
	if !halt_rotation:
		distance_traveled += DISTANCE_GAIN_RATE * delta * current_speed_modifier
		mesh_and_stopping_area_container.rotation.x = lerp(mesh_and_stopping_area_container.rotation.x, target_rotation, ROTATION_LERP_SPEED * delta)
		current_speed_modifier = 1.0
	else:
		current_speed_modifier = HALTED_SPEED_MODIFER

func handle_movement(delta : float):
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var prev_x = global_position.x
		global_position.x += -direction.z * SPEED * current_speed_modifier
		global_position.x = clamp(global_position.x, MIN_ANCHOR_POSITION, MAX_ANCHOR_POSITION)
		
		target_rotation = +direction.z * MAX_ROTATION
		
		# If we're moving and colliding with a platform, apply damage if cooldown allows
		if current_platform != null and abs(global_position.x - prev_x) > 0.001:
			if damage_cooldown_timer <= 0:
				anchor_is_dragging = true
				if is_instance_valid(current_platform) and current_platform.can_collide:
					current_platform.take_damage(1)
					damage_cooldown_timer = DAMAGE_COOLDOWN
			else:
				anchor_is_dragging = false
			
	else:
		target_rotation = 0.0
		
func handle_grab_camera(delta : float):
	current_fov = lerp(current_fov, target_fov, camera_lerp_speed * delta)
	camera.fov = current_fov
	
	if is_grabbed:
		target_fov = ZOOM_OUT_FOV
	else:
		target_fov = NORMAL_FOV

func handle_anchor_sounds():
	if halt_rotation && !has_played_impact && !audio_playing:
		has_played_impact = true
		audio_playing = true
		audio_player.volume_db = 6.0
		audio_player.stream = impact_sound
		audio_player.play()
		await audio_player.finished
		audio_playing = false
		
	if halt_rotation && anchor_is_dragging && !audio_playing:
		audio_playing = true
		audio_player.volume_db = 6.0
		audio_player.stream = dragging_sound
		audio_player.play()
		await audio_player.finished
		audio_playing = false

func _on_anchor_control_area_body_entered(body: Node3D) -> void:
	print_debug(body)
	if body is Player:
		body.can_control_anchor = true

func _on_anchor_control_area_body_exited(body: Node3D) -> void:
	if body is Player:
		body.can_control_anchor = false

func _on_stopping_area_body_entered(body: Node3D) -> void:
	if body.get_parent().get_parent() is SpawnableEntity:
		var spawnable_entity = body.get_parent().get_parent() as SpawnableEntity
		if spawnable_entity.can_collide:
			halt_rotation = true
			spawnable_entity.environment_spawner.is_falling = false

			if damage_cooldown_timer <= 0:
				spawnable_entity.take_damage(1)
				damage_cooldown_timer = DAMAGE_COOLDOWN
			
			# Save current platform reference
			current_platform = spawnable_entity

func _on_stopping_area_body_exited(body: Node3D) -> void:
	if body.get_parent().get_parent() is SpawnableEntity:
		has_played_impact = false
		var spawnable_entity = body.get_parent().get_parent() as SpawnableEntity
		if spawnable_entity.can_collide:
			spawnable_entity.environment_spawner.is_falling = true
			halt_rotation = false
			
			if current_platform == spawnable_entity:
				current_platform = null
