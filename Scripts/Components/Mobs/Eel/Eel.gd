class_name Eel extends Node3D

const SWIM_SPEED := 10.0

@onready var animation_player := $Eel/AnimationPlayer
@onready var eel_theme_player := $AudioStreamPlayer3D

@export var environment_spawner : EnvironmentSpawner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position.x = environment_spawner.player.anchor.global_position.x
	if !environment_spawner.player.changed_to_theme_music:
		eel_theme_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y += SWIM_SPEED * delta
	animation_player.play("Swim")


func _on_contact_area_body_entered(body: Node3D) -> void:
	if body is Player:
		body.velocity.y = body.JUMP_VELOCITY * 2
		body.controls_disabled = true
	
	var potential_spawned_entity = body.get_parent().get_parent()
	if potential_spawned_entity is SpawnableEntity:
		potential_spawned_entity.take_damage(5)
