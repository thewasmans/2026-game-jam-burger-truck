class_name ClientRequestUI
extends Node

@export var label:Label
@export var waiting:Slider

func set_request(value:String):
	label.text = value
	
func set_waiting(value:float):
	waiting.value = value
