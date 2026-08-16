shader_type canvas_item;

uniform float thickness = 0.01;
uniform float dash_count = 32.0;
uniform float dash_ratio = 0.5;
uniform float rotation_speed = 0.25;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);

void fragment() {
	// Center UV coordinates around (0, 0).
	vec2 centered = UV - vec2(0.5);

	// Distance from the center.
	float distance_from_center = length(centered);

	// Angle around the circle.
	float angle = atan(centered.y, centered.x);

	// Convert angle from [-PI, PI] to [0, 1].
	float normalized_angle = (angle + PI) / (2.0 * PI);

	// Rotate the dash pattern over time.
	normalized_angle += TIME * rotation_speed;

	// Repeat the pattern around the circumference.
	float dash_position = fract(normalized_angle * dash_count);

	// Determine whether this section is a dash or a gap.
	float dash_mask = step(dash_position, dash_ratio);

	// Keep the circle slightly inside the Sprite bounds
	// so the line does not get clipped at the edges.
	float circle_radius = 0.50 - thickness;

	float ring_distance = abs(distance_from_center - circle_radius);

	float ring_mask = 1.0 - smoothstep(
		thickness,
		thickness + fwidth(ring_distance),
		ring_distance
	);

	float alpha = dash_mask * ring_mask;

	COLOR = vec4(
		line_color.rgb,
		line_color.a * alpha
	);
}