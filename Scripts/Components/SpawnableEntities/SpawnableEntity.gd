class_name SpawnableEntity extends Node3D

var dag_scene: PackedScene

func _init():
	dag_scene = load("res://Components/Mobs/Dag/Dag.tscn")

@onready var sound_player_drop_scene := preload("res://Components/Utilities/SoundPlayerDrop.tscn")

const LEVEL_TO_START_SPAWNING := 30

@export var environment_spawner : EnvironmentSpawner
@export var can_collide := false
@export var health: int = 3

@export var particles_collection : Node3D

@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if particles_collection:
		particles_collection.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.y >= 25.0:
		queue_free()
	
	if environment_spawner.is_falling:
		global_position.y += environment_spawner.float_speed * delta

#func _on_collision_area_body_entered(body: Node3D) -> void:
	#if body.name == "StaticBody3D" and body.get_parent().name == "Anchor":
		#take_damage(1)
		
func take_damage(amount: int) -> void:
	health -= amount
	print("platform took damage!")
	
	shake_platform()
	
	if is_instance_valid(particles_collection):
		print_debug("should turn visible")
		particles_collection.visible = true
	
	if health <= 0:
		break_platform()
		
func shake_platform() -> void:
	var tween = create_tween()
	var original_position = position
	var shake_amount = 0.1
	var shake_duration = 0.2
	
	# Shake in random directions
	for i in range(3):
		var random_offset = Vector3(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		tween.tween_property(self, "position", original_position + random_offset, shake_duration / 6)
		tween.tween_property(self, "position", original_position, shake_duration / 6)
	
	# Ensure we return to the original position
	tween.tween_property(self, "position", original_position, shake_duration / 6)
		
func break_platform() -> void:
	var sound_player_drop_instance = sound_player_drop_scene.instantiate() as SoundPlayerDrop
	get_tree().root.add_child(sound_player_drop_instance)
	sound_player_drop_instance.global_position = global_position
	
	if is_instance_valid(particles_collection):
		# Make a copy of particles to keep them after platform is destroyed
		var particles_instance = particles_collection.duplicate()
		get_tree().root.add_child(particles_instance)
		particles_instance.global_position = global_position
		particles_instance.visible = true
		
		# Emit from all particle systems with dramatic settings
		for particle in particles_instance.get_children():
			if particle is GPUParticles3D:
				particle.emitting = true
				particle.amount = 80
				particle.explosiveness = 0.9
				particle.lifetime = 1.5
				particle.speed_scale = 2.0
				particle.one_shot = true
				
				if particle.process_material is ParticleProcessMaterial:
					var mat = particle.process_material as ParticleProcessMaterial
					mat.initial_velocity_min = 4.0
					mat.initial_velocity_max = 10.0
					mat.scale_min = 1.0
					mat.scale_max = 1.5
					
		if particles_instance.get_child_count() > 0 and particles_instance.get_child(0) is GPUParticles3D:
			var explosion = particles_instance.get_child(0).duplicate()
			particles_instance.add_child(explosion)
			explosion.emitting = true
			explosion.explosiveness = 1.0
			explosion.amount = 120
			explosion.lifetime = 1.0
			explosion.one_shot = true
		
		# Set up a timer to free the particles after they're done
		var timer = Timer.new()
		particles_instance.add_child(timer)
		timer.wait_time = 2.5  # Duration for the explosion effect
		timer.one_shot = true
		timer.timeout.connect(func(): particles_instance.queue_free())
		timer.start()
	
	queue_free()
