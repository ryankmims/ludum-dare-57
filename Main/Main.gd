class_name Main extends Node

@onready var main_menu_scene := preload("res://Utilities/MainMenu.tscn")
@onready var game_scene := preload("res://Prototyping/TestingDepth.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_scene(main_menu_scene)

func change_scene(scene : PackedScene):
	for child in get_children():
		child.queue_free()
	
	var scene_instance = scene.instantiate()
	add_child(scene_instance)
	
	scene_instance.main = self

func start_game():
	change_scene(game_scene)
