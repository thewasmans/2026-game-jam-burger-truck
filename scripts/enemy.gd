extends CharacterBody3D

class_name Enemy

@export var speed: float = 5.0
@export var target_position: Vector3 = Vector3.ZERO

func _physics_process(_delta: float) -> void:
	var direction: Vector3 = (target_position - global_transform.origin).normalized()

	if global_transform.origin.distance_to(target_position) > 1:
		velocity = direction * speed
	else:
		velocity = Vector3.ZERO

	move_and_slide()
