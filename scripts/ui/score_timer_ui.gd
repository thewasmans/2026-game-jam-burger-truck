extends Control

@export var _timer_label:Label
var _timer: float = 0.0

func _process(delta: float) -> void:
	_timer += delta
	_timer_label.text = "Open since: " + _format_time(_timer)

func _format_time(time_in_seconds: float) -> String:
	var _total_seconds = int(time_in_seconds)
	
	var _hours = _total_seconds / 3600
	var _minutes = (_total_seconds % 3600) / 60
	var _seconds = _total_seconds % 60
	
	return "%02d:%02d:%02d" % [_hours,_minutes,_seconds]
