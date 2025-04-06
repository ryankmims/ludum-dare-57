class_name Kelp extends Node3D

@onready var animation_player := $Kelp/AnimationPlayer
@onready var kelp_mesh := $Kelp 

@export var environment_spawner : EnvironmentSpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.speed_scale = randf_range(0.15, 0.5)
	animation_player.play("ArmatureAction")
	kelp_mesh.scale = kelp_mesh.scale * randf_range(1.0, 2.5)

func _process(delta: float) -> void:
	
	if global_position.y >= 23.0:
		queue_free()
	
	if environment_spawner.is_falling:
		global_position.y += environment_spawner.float_speed * delta
