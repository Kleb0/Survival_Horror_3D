shader_type spatial;

uniform sampler2D depth_tex : hint_depth_texture;
uniform float depthValue : hint_range (0.01, 0.2);

void fragment() {
    
	float depth = texture(depth_tex, SCREEN_UV).r;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2] [2]);
	ALBEDO = vec3(depth * depthValue);
	
}
