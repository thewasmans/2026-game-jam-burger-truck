class_name LeafParticleSystem
extends GPUParticles3D

@export var _emission_velocity: Vector3 = Vector3(0, -1, 0)

func _ready() -> void:
	_configure_particles()

func _configure_particles() -> void:
	process_material.direction = _emission_velocity
	process_material.spread = 15.0
	process_material.initial_velocity_min = 1.0
	process_material.initial_velocity_max = 3.0
	
	process_material.gravity = Vector3(0, -1.5, 0)
	
	process_material.hue_variation_min = -0.1
	process_material.hue_variation_max = 0.1
	
	_apply_wind(process_material)

func _apply_wind(target_material: ParticleProcessMaterial) -> void:
	speed_scale = 0.5
	target_material.collision_mode = ParticleProcessMaterial.COLLISION_HIDE_ON_CONTACT

func play():
	emitting = true
	await get_tree().create_timer(1).timeout
	emitting = false
