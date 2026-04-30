class_name ClientRequestUI
extends Control

@export var waiting: ProgressBar
	
func set_waiting(value:float):
	waiting.value = value
	
	var t = value / waiting.max_value
	var color = Color(0.705, 0.0, 0.068, 1.0).lerp(Color(0.443, 0.858, 0.001, 1.0), t)
	var style = waiting.get_theme_stylebox("fill")
	if style:
		style = style.duplicate()
		waiting.add_theme_stylebox_override("fill", style)
		
		if style is StyleBoxFlat:
			style.bg_color = color
