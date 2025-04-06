class_name Dag extends Node3D

@onready var dag_mesh := $DagMesh
@onready var animation_player := $DagMesh/AnimationPlayer
@onready var dag_ball_emitter := $DagMesh/Armature/Skeleton3D/BoneAttachment3D/DagBallEmitter

@onready var dag_ball_attack_scene := preload("res://Components/Mobs/Dag/DagAttacks/DagAttackBall.tscn")

@export var spawnable_entity : SpawnableEntity

var throw_timer := 0.0
var throw_interval := 5.0

var throwing := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	throw_timer = Time.get_unix_time_from_system()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !throwing:
		animation_player.play("Idle")
	
	dag_mesh.look_at(spawnable_entity.player.global_position)
	dag_mesh.global_rotation.x = 0.0
	dag_mesh.global_rotation.z = 0.0
	
	var now = Time.get_unix_time_from_system()
	if now - throw_timer >= throw_interval:
		throw()

func throw():
	if !throwing:
		throwing = true
		var dag_ball_attack_scene_instance = dag_ball_attack_scene.instantiate() as DagBallAttack
		var offset_player_position := Vector3(spawnable_entity.player.global_position.x, spawnable_entity.player.global_position.y - 5.0, spawnable_entity.player.global_position.z)
		dag_ball_attack_scene_instance.direction = global_position.direction_to(offset_player_position)
		add_child(dag_ball_attack_scene_instance)
		dag_ball_attack_scene_instance.global_position = dag_ball_emitter.global_position
		dag_ball_attack_scene_instance.environment_spawner = spawnable_entity.environment_spawner
		animation_player.play("Hurl")
		await get_tree().create_timer(1.6667).timeout
		throwing = false
