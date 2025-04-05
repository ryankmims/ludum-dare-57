class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 7.5

@onready var player_ui := $PlayerUI
@onready var control_anchor_label := $PlayerUI/ControlAnchorLabel

@onready var headlamp_light := $HeadlampLight

@export var anchor : DepthAnchor
@export var game_scene : GameScene

## Sanity
## 		You lose sanity at a fixed rate
##		you need to collect light/sanity to continue the journey
@export var sanity := 1.0

var can_control_anchor := false
var player_offset_at_grab : Vector3

var dead := false

func _process(delta: float) -> void:
	if dead:
		game_scene.main.go_insane()
	
	check_for_fall_death() 
	handle_light(delta)
	
	control_anchor_label.visible = can_control_anchor
	if can_control_anchor:
		if Input.is_action_just_pressed("control_anchor"):
			player_offset_at_grab = global_position - anchor.global_position
		
		if Input.is_action_pressed("control_anchor"):
			anchor.is_grabbed = true
		else:
			anchor.is_grabbed = false

func handle_light(delta : float):
	sanity -= 0.05 * delta
	headlamp_light.light_energy = pow(sanity / 5.0, 3.0) 
	
	if sanity <= 0.0:
		dead = true

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

func add_light(amount : int):
	sanity += amount

func check_for_fall_death():
	if global_position.y <= -25.0:
		dead = true
