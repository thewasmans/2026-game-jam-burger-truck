extends Node3D

@export var _mesh : MeshInstance3D
@export var _doneness_bar : ProgressBar
@export var _shader : Shader
@export var _camera: Camera3D
@export var _bar_height := 1.0
@export var _cook_time := 5.0
var _current_time := 0.0
var _is_cooking := false
var _material: ShaderMaterial
var _raw = Color(0.82,0.23,0.18)
var _cooked = Color(0.20,0.09,0.02)

func _ready():
	if _doneness_bar:
		_doneness_bar.visible = false
	if not _mesh:
		push_error("No Mesh assigned!")
		return
		
	_material = ShaderMaterial.new()
	_material.shader = _shader
	_mesh.material_override = _material	
	_material.set_shader_parameter("_cook_progress", 0.0)

func _process(delta):
	if not _is_cooking or not _material:
		return
		
	_current_time += delta
	var _progress = clamp(_current_time / _cook_time, 0.0,1.0)
	
	_material.set_shader_parameter("_cook_progress", _progress)
	
	if _doneness_bar:
		_doneness_bar.value = _progress * 100.0
		var _bar_color = _raw.lerp(_cooked,_progress)
		_doneness_bar.modulate = _bar_color
	
	if _doneness_bar and _camera:
		var _steak_pos_3d = global_transform.origin
		_steak_pos_3d.y += _bar_height
		
		var _screen_pos = _camera.unproject_position(_steak_pos_3d)
		
		_doneness_bar.rect_position = _screen_pos - (_doneness_bar.rect_size / 2)
	
func start_cooking():
	_is_cooking = true
	if _doneness_bar:
		_doneness_bar.visible = true
	
func stop_cooking():
	_is_cooking = false
	if _doneness_bar:
		_doneness_bar.visible = false
