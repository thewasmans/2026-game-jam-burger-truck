extends Node3D

var _current_ingredient: Node3D

func _process(_delta: float) -> void:
	if _current_ingredient:
		var space_state = get_world_3d().direct_space_state
		var mouse_pos = get_viewport().get_mouse_position()

		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000

		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		
		if result:
			var tile := result.collider as Node
			if tile:
				if tile.has_meta("tile"):
					var tile_3D := tile as Node3D
					var meta_data := tile_3D.get_meta("tile") as Vector3
					_tile_position = Vector2(meta_data.x, meta_data.z)
					_current_furniture_instance.global_position = tile_3D.global_position
