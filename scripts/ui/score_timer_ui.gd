class_name BoardUI
extends Node3D

@export var timer_label: Label3D
@export var mesh_instance: MeshInstance3D
var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	timer_label.text = "OPEN SINCE " + format_time(timer)

func format_time(time_in_seconds: float) -> String:
	var total_seconds = (time_in_seconds)
	
	var _hours = total_seconds / 3600.0
	var minutes = (int(total_seconds) % 3600) / 60.0
	var seconds = int(total_seconds) % 60
	
	return "%02d:%02d" % [minutes, seconds]

func set_reputation(value:float):
	assert(value >= 0 or value <= 1, "[ BOARDUI ] Value should in range [0, 1]")
	mesh_instance.get_active_material(0).set_shader_parameter("_fill_amount", value)
	
