extends Node3D

@export var _mesh : MeshInstance3D
@export var _shader : Shader
var _material: ShaderMaterial
var _raw = Color(0.82,0.23,0.18)
var _cooked = Color(0.20,0.09,0.02)

func _ready():
	if not _mesh:
		push_error("No Mesh assigned!")
		return
		
	_material = ShaderMaterial.new()
	_material.shader = _shader
	_mesh.material_override = _material	
	set_progress(0.0)

func set_progress(value: float):
	value = clamp(value, 0.0, 1.0)
	if _material:
		_material.set_shader_parameter("_cook_progress", value)
