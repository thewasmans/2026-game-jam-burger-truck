class_name ClientRequestUI
extends Control

@export var waiting:Slider
	
func set_waiting(value:float):
	waiting.value = value
	
	var t = value / waiting.max_value
	var color = Color(1.0, 0.2, 0.2).lerp(Color(0.2, 1.0, 0.2, 1.0), t)
	var style = waiting.get_theme_stylebox("grabber_area")
	if style:
		style = style.duplicate()
		waiting.add_theme_stylebox_override("grabber_area", style)
		
		if style is StyleBoxFlat:
			style.bg_color = color
