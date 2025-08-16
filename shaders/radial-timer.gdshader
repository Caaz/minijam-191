shader_type spatial;
render_mode unshaded;

uniform float amount:hint_range(0.0, 1.0, 0.001);
uniform vec3 albedo:source_color;
uniform sampler2D icon:hint_default_transparent;
void fragment() {
	// Centered uv
	vec2 uv = UV-vec2(.5);

	float distance_to_center = distance(vec2(0), uv);
	// Two circles
	float outer = step(distance_to_center, .5);
	float inner = step(distance_to_center, .4);
	// subtract one from the other!
	float ring = outer-inner;
	
	// Get the angle from the center
	float angle = atan(uv.y, uv.x);
	// make it a range from 0-1, because I hate radians
	angle = fract(angle / (PI*2.));
	// use our amount to set the range of the angle we want.
	angle = step(angle, amount);
	
	vec4 color = texture(icon, UV);
	color.rgb = mix(albedo, color.rgb, color.a);
	color.rgb = mix(vec3(0), color.rgb, max(angle, .4));
	// only show the ring when it's within the amount defined
	ALPHA = mix(inner, 1, ring * (angle+color.a));
	
	ALBEDO = color.rgb;
}