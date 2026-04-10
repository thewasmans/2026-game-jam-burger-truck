shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_test_default, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec3 _base_color: source_color = vec3(0.82, 0.23, 0.18);
uniform vec3 _cooked_color: source_color = vec3(0.20, 0.09, 0.02);
uniform float _cook_progress : hint_range(0.0, 0.1)= 0.0;

void fragment() {
	ALBEDO = mix(_base_color.rgb, _cooked_color.rgb, _cook_progress);
}


