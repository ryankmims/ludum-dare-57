class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 7.5

@onready var player_ui := $PlayerUI
@onready var control_anchor_label := $PlayerUI/ControlAnchorLabel

@onready var player_mesh := $Man
@onready var animation_player := $Man/AnimationPlayer

@onready var headlamp_light := $Man/Armature/Skeleton3D/BoneAttachment3D/HeadlampLight

@export var anchor : DepthAnchor
@export var game_scene : GameScene

var walking := false

## Sanity
## 		You lose sanity at a fixed rate
##		you need to collect light/sanity to continue the journey
@export var sanity := 1.0

var can_control_anchor := false
var player_offset_at_grab : Vector3
var just_grabbed_anchor := false

var dead := false

func _process(delta: float) -> void:
	if dead:
		game_scene.main.go_insane()
	
	check_for_fall_death() 
	handle_light(delta)
	
	control_anchor_label.visible = can_control_anchor
	if can_control_anchor:
		if Input.is_action_just_pressed("control_anchor"):
			just_grabbed_anchor = true
			print_debug("just grabbed anchor")
			player_offset_at_grab = global_position - anchor.global_position
		
		if Input.is_action_pressed("control_anchor"):
			anchor.is_grabbed = true
		else:
			anchor.is_grabbed = false
	
	if walking && !anchor.is_grabbed:
		animation_player.play("Walk")
	elif anchor.is_grabbed:
		if just_grabbed_anchor:
			player_mesh.look_at(anchor.global_position)
			player_mesh.rotation.x = 0.0
			player_mesh.rotation.z = 0.0
			animation_player.play("GrabbedBeingPulledStart")
			await get_tree().create_timer(0.41).timeout
			just_grabbed_anchor = false
		else:
			animation_player.play("GrabbedAndBeingPulled")
	else:
		animation_player.play("Idle")
		

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
			walking = true
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			walking = false
		
		var target_rotation = atan2(-direction.x, -direction.z)  # Yaw rotation
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, target_rotation, delta * 10.0)  # Smooth rotation
		
	else:
		global_position = anchor.global_position + player_offset_at_grab
	move_and_slide()

func add_light(amount : int):
	sanity += amount

func check_for_fall_death():
	if global_position.y <= -25.0:
		dead = true
