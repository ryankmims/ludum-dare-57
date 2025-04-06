class_name PoemScreen extends Node3D

@export var main : Main

@onready var audio_player := $AudioStreamPlayer2D
@onready var skip_label := $SkipLabel

var poem_timer := 0.0
var poem_length := 16.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	poem_timer = Time.get_unix_time_from_system()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_poem()
	
	skip_label.label_settings.font_color.a += 0.25 * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		start_game()

func start_game():
	main.start_game()

func handle_poem():
	#await audio_player.finished
	#start_game()
	var now = Time.get_unix_time_from_system()
	if now - poem_timer >= poem_length:
		start_game()
