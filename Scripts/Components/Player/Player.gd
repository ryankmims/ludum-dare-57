class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY =  8

@onready var ld57_anchor_down_theme := preload("res://Audio/Music/LD57_light_has_returned.wav")
@onready var core_ambient_theme := preload("res://Audio/Music/core_ambient_theme.wav")

@onready var first_stanza := preload("res://Audio/Vocals/01_the_place_below_my_anchor_falls.wav")
@onready var second_stanza := preload("res://Audio/Vocals/02_betwixt_the.wav")
@onready var third_stanza := preload("res://Audio/Vocals/03_of_blackness_where.wav")
@onready var fourth_stanza := preload("res://Audio/Vocals/04_it_takes_my_mind.wav")

@onready var fifth_reverse := preload("res://Audio/Vocals/05_rev.wav")
@onready var sixth_reverse := preload("res://Audio/Vocals/06_rev.wav")
@onready var seventh_reverse := preload("res://Audio/Vocals/07_rev.wav")
@onready var eighth_reverse := preload("res://Audio/Vocals/08_rev.wav")

@onready var my_light_is_fading := preload("res://Audio/Vocals/my_light_is_fading.wav")

@onready var player_ui := $PlayerUI
@onready var left_mouse_button_sprite := $PlayerUI/LeftMouseButtonSprite
@onready var control_anchor_label := $PlayerUI/LeftMouseButtonSprite/ControlAnchorLabel

@onready var movement_sprite := $PlayerUI/MovementSprite
@onready var jump_sprite := $PlayerUI/JumpSprite

@onready var blackout_screen := $PlayerUI/BlackoutScreen

@onready var player_mesh := $Man
@onready var animation_player := $Man/AnimationPlayer

@onready var headlamp_light := $Man/Armature/Skeleton3D/BoneAttachment3D/HeadlampLight
@onready var omni_light := $Man/Armature/Skeleton3D/BoneAttachment3D/OmniLight3D

@onready var music_player := $MusicPlayer
@onready var voice_player := $VoicePlayer

@export var anchor : DepthAnchor
@export var game_scene : GameScene

@export var winning_distance := 200

var walking := false

## Sanity
## 		You lose sanity at a fixed rate
##		you need to collect light/sanity to continue the journey
@export var sanity := 1.0

var can_control_anchor := false
var player_offset_at_grab : Vector3
var just_grabbed_anchor := false

var sanity_warning_timer := 0.0
var sanity_warning_interval := 15.0

var flicker_timer := 0.0
var flicker_target := 0.0

var dead := false
var changed_to_theme_music := false

var death_fade_timer := 0.0
var death_fade_interval := 5.0
var set_death_timer := false

var win_fade_timer := 0.0
var win_fade_interval := 5.0
var set_win_timer := false

var won := false

var has_moved := false
var has_grabbed := false
var has_jumped := false

func _ready() -> void:
	blackout_screen.visible = true
	music_player.play()

func _process(delta: float) -> void:
	var now = Time.get_unix_time_from_system()
	
	if blackout_screen.color.a >= 0.0:
		blackout_screen.color.a -= 0.25 * delta
	
	handle_music()
	handle_low_health(delta)
	
	if dead:
		headlamp_light.light_energy = 0.0
		headlamp_light.light_volumetric_fog_energy = 0.0
		omni_light.light_energy = 0.0
		omni_light.omni_range = 0.0
		
		if !set_death_timer:
			death_fade_timer = Time.get_unix_time_from_system()
			set_death_timer = true
		if now - death_fade_timer >= death_fade_interval:
			game_scene.main.go_insane()
		else:
			blackout_screen.color.a += 0.5 * delta
	
	if !dead:
		if anchor.distance_traveled >= winning_distance:
			won = true
			if !set_win_timer:
				win_fade_timer = Time.get_unix_time_from_system()
				set_win_timer = true
			
			if now - win_fade_timer >= win_fade_interval:
				game_scene.main.win_game()
			else:
				blackout_screen.color.r = 1.0
				blackout_screen.color.g = 1.0
				blackout_screen.color.b = 1.0
				blackout_screen.color.a += 0.5 * delta
		
		if !won:
			check_for_fall_death() 
			handle_light(delta)
			
			left_mouse_button_sprite.visible = can_control_anchor && !anchor.is_grabbed
			
			if can_control_anchor:
				if Input.is_action_just_pressed("control_anchor"):
					just_grabbed_anchor = true
					print_debug("just grabbed anchor")
					player_offset_at_grab = global_position - anchor.global_position
				
				if Input.is_action_pressed("control_anchor"):
					anchor.is_grabbed = true
				else:
					anchor.is_grabbed = false
			
			if walking && !anchor.is_grabbed:
				animation_player.play("Walk")
			elif anchor.is_grabbed:
				if just_grabbed_anchor:
					player_mesh.look_at(anchor.global_position)
					player_mesh.rotation.x = 0.0
					player_mesh.rotation.z = 0.0
					animation_player.play("GrabbedBeingPulledStart")
					await get_tree().create_timer(0.41).timeout
					just_grabbed_anchor = false
				else:
					animation_player.play("GrabbedAndBeingPulled")
			else:
				animation_player.play("Idle")
		
	handle_control_tutorial()
	handle_depths()

func handle_music():
	await music_player.finished
	
	if anchor.distance_traveled >= 110.0 && changed_to_theme_music:
		music_player.stream = core_ambient_theme
	
	if anchor.distance_traveled >= 90.0 && !changed_to_theme_music:
		music_player.stream = ld57_anchor_down_theme
		changed_to_theme_music = true

	music_player.play()

func handle_light(delta: float) -> void:
	sanity -= 0.05 * delta
	sanity = clamp(sanity, 0.0, 5.0)
	
	var sanity_factor = (sanity / 5.0) * (sanity / 5.0) * (sanity / 5.0)
	var base_energy = 15 * sanity_factor
	var omni_base_energy = 0.5 * sanity_factor
	
	headlamp_light.light_energy = max(1.0, base_energy + flicker_target)
	headlamp_light.light_volumetric_fog_energy = max(1.0, base_energy + flicker_target)
	
	omni_light.light_energy = max(0.2, omni_base_energy + flicker_target)
	omni_light.omni_range = lerp(0.5, 2.5, sanity_factor)
	
	if sanity <= 0.0:
		dead = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not anchor.is_grabbed:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			has_jumped = true
			velocity.y = JUMP_VELOCITY

		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			has_moved = true
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			walking = true
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			walking = false
		
		var target_rotation = atan2(-direction.x, -direction.z)  # Yaw rotation
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, target_rotation, delta * 10.0)  # Smooth rotation
		
	else:
		global_position = anchor.global_position + player_offset_at_grab
	move_and_slide()

func add_light(amount : int):
	sanity += amount

func check_for_fall_death():
	if global_position.y <= -20.0:
		dead = true

func handle_low_health(delta: float = 0.0) -> void:
	var now = Time.get_unix_time_from_system()
	if sanity <= 1.5:
		# Voice warning
		if now - sanity_warning_timer >= sanity_warning_interval:
			sanity_warning_timer = now
			voice_player.stream = my_light_is_fading
			voice_player.play()
		
		# Light flickering effect
		flicker_timer += delta
		if flicker_timer >= 0.1:
			flicker_timer = 0.0
			var flicker_intensity = 0.5 * (1.0 - sanity / 1.5)
			flicker_target = randf_range(-flicker_intensity, flicker_intensity * 0.7)
		
		flicker_target = lerp(flicker_target, 0.0, delta * 0.5)
	else:
		flicker_target = 0.0

func handle_control_tutorial():
	jump_sprite.visible = !has_jumped
	movement_sprite.visible = !has_moved

var talking = false

var first_stanza_done = false
var second_stanza_done = false
var third_stanza_done = false
var fourth_stanza_done = false

var fifth_reverse_done = false
var sixth_reverse_done = false
var seventh_reverse_done = false
var eighth_reverse_done = false

func handle_depths():
	if anchor.distance_traveled >= 20.0 && !first_stanza_done:
		first_stanza_done = true
		voice_player.stream = first_stanza
		voice_player.play()
	
	if anchor.distance_traveled >= 40.0 && !second_stanza_done:
		second_stanza_done = true
		voice_player.stream = second_stanza
		voice_player.play()
	
	if anchor.distance_traveled >= 60.0 && !third_stanza_done:
		third_stanza_done = true
		voice_player.stream = third_stanza
		voice_player.play()
	
	if anchor.distance_traveled >= 80.0 && !fourth_stanza_done:
		fourth_stanza_done = true
		voice_player.stream = fourth_stanza
		voice_player.play()
	
	if anchor.distance_traveled >= 110.0 && !fifth_reverse_done:
		fifth_reverse_done = true
		voice_player.stream = fifth_reverse
		voice_player.play()
	
	if anchor.distance_traveled >= 130.0 && !sixth_reverse_done:
		sixth_reverse_done = true
		voice_player.stream = sixth_reverse
		voice_player.play()
	
	if anchor.distance_traveled >= 150.0 && !seventh_reverse_done:
		seventh_reverse_done = true
		voice_player.stream = seventh_reverse
		voice_player.play()
	
	if anchor.distance_traveled >= 170.0 && !eighth_reverse_done:
		eighth_reverse_done = true
		voice_player.stream = eighth_reverse
		voice_player.play()
