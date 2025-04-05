class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 7.5

@onready var player_ui := $PlayerUI
@onready var control_anchor_label := $PlayerUI/ControlAnchorLabel

@export var anchor : DepthAnchor

var can_control_anchor := false
var player_offset_at_grab : Vector3

func _process(delta: float) -> void:
	control_anchor_label.visible = can_control_anchor
	if can_control_anchor:
		if Input.is_action_just_pressed("control_anchor"):
			player_offset_at_grab = global_position - anchor.global_position
		
		if Input.is_action_pressed("control_anchor"):
			anchor.is_grabbed = true
		else:
			anchor.is_grabbed = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not anchor.is_grabbed:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		global_position = anchor.global_position + player_offset_at_grab
	move_and_slide()
