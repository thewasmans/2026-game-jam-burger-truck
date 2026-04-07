extends Node3D

@export var timer_label: Label3D
var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	timer_label.text = "OPEN\n SINCE\n " + format_time(timer)

func format_time(time_in_seconds: float) -> String:
	var total_seconds = int(time_in_seconds)
	
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	
	return "%02d:%02d" % [minutes, seconds]
