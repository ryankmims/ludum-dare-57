class_name SpawnableEntity extends Node3D

@export var environment_spawner : EnvironmentSpawner
@export var can_collide := false
@export var health: int = 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if environment_spawner.is_falling:
		global_position.y += environment_spawner.FLOAT_SPEED * delta

#func _on_collision_area_body_entered(body: Node3D) -> void:
	#if body.name == "StaticBody3D" and body.get_parent().name == "Anchor":
		#take_damage(1)
		
func take_damage(amount: int) -> void:
	health -= amount
	print("platform took damage!")
	
	if health <= 0:
		break_platform()
		
func break_platform() -> void:
	queue_free()
