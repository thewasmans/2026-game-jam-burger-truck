shader_type spatial;

render_mode blend_mix, cull_disabled;

uniform vec4 shadow_color: source_color;
uniform float strength = 0.8;

void fragment() {
	float facing = dot(NORMAL, VIEW);
	float gradient = 1.0 - abs(facing);
	
	gradient = smoothstep(0.2, 1.0, gradient);
	
	ALBEDO = shadow_color.rgb * gradient * strength;
	
	ALPHA = gradient * strength;
	ALPHA = max(ALPHA, 0.05);
}