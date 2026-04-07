extends Node3D

@export var timer_label: Label3D
var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	timer_label.text = "OPEN\n SINCE\n " + format_time(timer)

func format_time(time_in_seconds: float) -> String:
	var total_seconds = (time_in_seconds)
	
	var _hours = total_seconds / 3600.0
	var minutes = (int(total_seconds) % 3600) / 60.0
	var seconds = int(total_seconds) % 60
	
	return "%02d:%02d" % [minutes, seconds]
