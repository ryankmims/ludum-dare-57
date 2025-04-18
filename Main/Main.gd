class_name Main extends Node

@onready var main_menu_scene := preload("res://Utilities/MainMenu.tscn")
@onready var game_scene := preload("res://Prototyping/TestingDepth.tscn")
@onready var poem_screen := preload("res://Utilities/PoemScreen.tscn")
@onready var insanity_screen := preload("res://Utilities/InsanityScreen.tscn")
@onready var win_screen := preload("res://Utilities/WinScreen.tscn")

var number_of_deaths := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_scene(main_menu_scene)

func change_scene(scene : PackedScene):
	for child in get_children():
		child.queue_free()
	
	var scene_instance = scene.instantiate()
	scene_instance.main = self
	add_child(scene_instance)

func start_game():
	change_scene(game_scene)

func go_insane():
	change_scene(insanity_screen)

func start_poem():
	change_scene(poem_screen)

func win_game():
	change_scene(win_screen)

## TODO: Make this work without showing controls/fade in or opening scene
func restart_game():
	start_game()
