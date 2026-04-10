shader_type spatial;

uniform sampler2D _albedo_texture;
uniform float _fill_amount: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 _uv = UV;
	
	vec4 _texture = texture(_albedo_texture,_uv);
	
	if (_uv.x > _fill_amount) {
		discard;
	}
	
	ALBEDO = _texture.rgb;
	ALPHA = _texture.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
