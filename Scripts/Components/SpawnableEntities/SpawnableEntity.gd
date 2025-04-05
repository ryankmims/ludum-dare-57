class_name SpawnableEntity extends Node3D

@export var environment_spawner : EnvironmentSpawner
@export var can_collide := false
@export var health: int = 3

@export var particles_collection : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if particles_collection:
		particles_collection.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if environment_spawner.is_falling:
		global_position.y += environment_spawner.float_speed * delta

#func _on_collision_area_body_entered(body: Node3D) -> void:
	#if body.name == "StaticBody3D" and body.get_parent().name == "Anchor":
		#take_damage(1)
		
func take_damage(amount: int) -> void:
	health -= amount
	print("platform took damage!")
	
	if is_instance_valid(particles_collection):
		print_debug("should turn visible")
		particles_collection.visible = true
	
	if health <= 0:
		break_platform()
		
func break_platform() -> void:
	queue_free()
