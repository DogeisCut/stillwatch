shader_type canvas_item;

uniform vec4 fill_color : source_color = vec4(1.0);
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float outline_thickness = 2.0;
uniform int polygon_sides = 0;
uniform float polygon_rotation_radians = 0.0;

varying vec2 local_position;
varying vec2 quad_half_size;

// TODO: round line joins toggle, like stroke-linecap="round" and stroke-linecap="round" in svg

vec2 rotate_vector(vec2 position, float radians)
{
	float cosine_value = cos(radians);
	float sine_value = sin(radians);
	return vec2(
		position.x * cosine_value - position.y * sine_value,
		position.x * sine_value + position.y * cosine_value
	);
}

float smin(float a, float b, float k)
{
	float h = clamp(0.5 + 0.5*(b - a)/k, 0.0, 1.0);
	return mix(b, a, h) - k*h*(1.0 - h);
}

float signed_distance_circle(vec2 position)
{
	return length(position) - 1.0;
}

float signed_distance_dot(vec2 position)
{
	return length(position);
}

float signed_distance_line(vec2 position)
{
	return abs(position.y) - 0.05;
}

float signed_distance_regular_polygon(vec2 position, int sides, out float unscaled_distance)
{
	float angle = atan(position.y, position.x);
	float sector_angle = 6.28318530718 / float(sides);
	float projected_distance = cos(floor(0.5 + angle / sector_angle) * sector_angle - angle) * length(position);
	float circumradius_scale = cos(3.14159265359 / float(sides));
	unscaled_distance = projected_distance - circumradius_scale;
	return projected_distance / circumradius_scale - 1.0;
}

void vertex()
{
	quad_half_size = abs(VERTEX);
	vec2 expansion = sign(VERTEX) * outline_thickness * 2.0; //doubling accounts for sharp corners.
	VERTEX += expansion;
	local_position = VERTEX;
}

void fragment()
{
	vec2 normalized_position = local_position / quad_half_size;
	normalized_position = rotate_vector(normalized_position, polygon_rotation_radians);

	float signed_distance;
	float outline_distance;

	if (polygon_sides <= 0)
	{
		signed_distance = signed_distance_circle(normalized_position);
		outline_distance = signed_distance;
	}
	else if (polygon_sides == 1)
	{
		signed_distance = signed_distance_dot(normalized_position) - 0.1;
		outline_distance = signed_distance;
	}
	else if (polygon_sides == 2)
	{
		signed_distance = signed_distance_line(normalized_position);
		outline_distance = signed_distance;
	}
	else
	{
		signed_distance = signed_distance_regular_polygon(
			normalized_position,
			polygon_sides,
			outline_distance
		);
	}

	float fill_mask = step(signed_distance, 0.0);
	float outline_mask = step(outline_distance, outline_thickness / quad_half_size.x) * (1.0 - fill_mask);

	float visible_mask = fill_mask + outline_mask;
	if (visible_mask < 0.5)
		discard;

	COLOR = fill_color * fill_mask + outline_color * outline_mask;
}
