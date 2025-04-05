extends CharacterBody3D

const ANCHOR_GRAVITY_BOUY_MODIFIER := 0.235
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var max_downward_velocity := 15.0

var is_grabbed := false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * ANCHOR_GRAVITY_BOUY_MODIFIER * delta
	
	if is_grabbed:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	if velocity.y <= -max_downward_velocity:
		velocity.y = -max_downward_velocity
	move_and_slide()
