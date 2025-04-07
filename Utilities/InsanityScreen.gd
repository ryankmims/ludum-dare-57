class_name InsanityScreen extends Node3D

@onready var tips := $InsanityScreenUI/Tips

@export var main : Main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main.number_of_deaths += 1
	
	var count = 1
	for tip in tips.get_children():
		if count <= main.number_of_deaths:
			tip.visible = true
		count += 1
	
	if main.number_of_deaths == 69:
		$"69thTip".visible = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	main.restart_game()
