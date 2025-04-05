class_name Anchor extends CharacterBody3D

const ANCHOR_GRAVITY_BOUY_MODIFIER := 0.235
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const ZOOM_OUT_FOV := 90.0
const NORMAL_FOV := 75.0

@onready var camera := $Camera3D

@export var max_downward_velocity := 15.0
@export var camera_lerp_speed: float = 5.0

var is_grabbed := false
var current_fov = NORMAL_FOV
var target_fov = NORMAL_FOV

func _process(delta: float) -> void:
	handle_grab_camera(delta)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * ANCHOR_GRAVITY_BOUY_MODIFIER * delta
	
	if is_grabbed:
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = -direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.z, 0, SPEED)

	if velocity.y <= -max_downward_velocity:
		velocity.y = -max_downward_velocity
	move_and_slide()

func handle_grab_camera(delta : float):
	current_fov = lerp(current_fov, target_fov, camera_lerp_speed * delta)
	camera.fov = current_fov
	
	if is_grabbed:
		target_fov = ZOOM_OUT_FOV
	else:
		target_fov = NORMAL_FOV

func _on_anchor_control_area_body_entered(body: Node3D) -> void:
	print_debug(body)
	if body is Player:
		body.can_control_anchor = true


func _on_anchor_control_area_body_exited(body: Node3D) -> void:
	if body is Player:
		body.can_control_anchor = false
