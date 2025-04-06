class_name SoundPlayerDrop extends Node3D

@onready var explosion_sound := preload("res://Audio/SoundEffects/exploding_sound.wav")

@onready var audio_player := $AudioStreamPlayer3D

var audio_playing := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !audio_playing:
		print_debug("should play audio")
		audio_playing = true
		audio_player.stream = explosion_sound
		audio_player.volume_db = 10.0
		audio_player.play()
		await audio_player.finished
		audio_playing = false
		queue_free()
