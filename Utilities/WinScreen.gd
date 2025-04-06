class_name WinScreen extends Node3D

@onready var audio_player := $AudioStreamPlayer2D


@export var main : Main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	main.restart_game()
