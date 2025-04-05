class_name Collectable extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collectable_area_body_entered(body: Node3D) -> void:
	if body is Player:
		body.add_light(1)
		print_debug(body.sanity)
		queue_free()
