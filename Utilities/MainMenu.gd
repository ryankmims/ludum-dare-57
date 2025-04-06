class_name MainMenu extends Node3D

@onready var man := $Man
@onready var man_animation_player := $Man/AnimationPlayer

@onready var main_menu_ui := $MainMenuUI

@onready var audio_player := $AudioStreamPlayer2D
@onready var ambient_player := $AudioStreamPlayer2D2

@onready var blackout_screen := $BlackoutScreen

@export var main : Main

var should_dampen_sound := false
var sound_dampen_timer := 0.0
var sound_dampen_interval := 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var now = Time.get_unix_time_from_system()
	man_animation_player.play("Idle")
	
	handle_main_menu_music()
	handle_ambient_sound()
	
	if should_dampen_sound:
		if now - sound_dampen_timer >= sound_dampen_interval:
			main.start_poem()
		else:
			blackout_screen.color.a += 0.5 * delta
			audio_player.volume_db -= 10.0 * delta

func handle_main_menu_music():
	await audio_player.finished
	audio_player.play()

func handle_ambient_sound():
	await ambient_player.finished
	ambient_player.play()

func _on_start_button_pressed() -> void:
	sound_dampen_timer = Time.get_unix_time_from_system()
	should_dampen_sound = true
	main_menu_ui.visible = false
	blackout_screen.visible = true
