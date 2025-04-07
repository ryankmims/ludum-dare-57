class_name DagBallAttack extends Node3D

@onready var flying_sound := preload("res://Audio/SoundEffects/darkness_ball_sound_flying.wav")

@onready var audio_player := $AudioStreamPlayer3D

@export var environment_spawner : EnvironmentSpawner
@export var home_platform : SpawnableEntity

var direction : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player.stream = flying_sound
	audio_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(environment_spawner):
		global_position.y += environment_spawner.float_speed * delta
	
	#global_position = global_position.move_toward(direction, delta * 10.5)
	global_position += direction * delta * 10.5


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		print_debug("hit player")
		body.sanity -= 1.5
		
		visible = false
		
		audio_player.stream = flying_sound
		audio_player.play()
		
		await get_tree().create_timer(2.0).timeout
		queue_free()
		
	if body.get_parent().get_parent() is SpawnableEntity:
		if body.get_parent().get_parent() != home_platform:
			body.get_parent().get_parent().take_damage(5)
