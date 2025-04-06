extends Area3D

func _ready() -> void:
	if not is_connected("body_entered", _on_body_entered):
		connect("body_entered", _on_body_entered)

func _on_body_entered(_body: Node3D) -> void:
	pass
	#if body is StaticBody3D:
		#var mesh_instance = body.get_parent()
		#if mesh_instance is MeshInstance3D:
			#var platform = mesh_instance.get_parent()
			#if platform is SpawnableEntity:
				#platform.take_damage(1)
