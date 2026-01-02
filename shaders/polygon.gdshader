shader_type canvas_item;

uniform vec4 fill_color : source_color = vec4(1.0);
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float outline_thickness = 2.0;
uniform int polygon_sides = 0;
//uniform float polygon_rotation_radians = 0.0;

varying vec2 local_position;
varying vec2 quad_half_size;

const float TWO_PI = 6.28318530718;

//vec2 rotate_vector(vec2 position, float radians)
//{
	//float c = cos(radians);
	//float s = sin(radians);
	//return vec2(
		//position.x * c - position.y * s,
		//position.x * s + position.y * c
	//);
//}

float signed_distance_circle(vec2 position)
{
	return length(position) - 1.0;
}

float signed_distance_rect(vec2 position, vec2 size)
{
	vec2 d = abs(position) - size;
	return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float signed_distance_regular_polygon_edges(vec2 p, int sides)
{
	float minDist = 1e20;
	bool inside = true;

	for (int i = 0; i < sides; ++i)
	{
		float aAng = float(i) * TWO_PI / float(sides);
		float bAng = float(i + 1) * TWO_PI / float(sides);

		vec2 a = vec2(cos(aAng), sin(aAng));
		vec2 b = vec2(cos(bAng), sin(bAng));
		vec2 ab = b - a;
		vec2 ap = p - a;

		float abLen2 = dot(ab, ab);
		float t = 0.0;
		if (abLen2 > 0.0)
			t = clamp(dot(ap, ab) / abLen2, 0.0, 1.0);

		vec2 closest = a + ab * t;
		float d = length(p - closest);
		minDist = min(minDist, d);

		float crossz = ab.x * ap.y - ab.y * ap.x;
		if (crossz < 0.0)
			inside = false;
	}

	return inside ? -minDist : minDist;
}

void vertex()
{
	quad_half_size = abs(VERTEX);
	vec2 expansion = sign(VERTEX) * outline_thickness;
	VERTEX += expansion;
	local_position = VERTEX;
}

void fragment()
{
	float min_half = min(quad_half_size.x, quad_half_size.y);

	vec2 normalized_position = local_position / min_half;
	//normalized_position = rotate_vector(normalized_position, polygon_rotation_radians);

	vec2 rect_normalized_size = quad_half_size / min_half;

	float signed_distance = 1.0;

	if (polygon_sides <= 0)
	{
		signed_distance = signed_distance_circle(normalized_position);
	}
	else if (polygon_sides == 1)
	{
		signed_distance = signed_distance_rect(normalized_position, rect_normalized_size);
	}
	else if (polygon_sides == 2)
	{
		signed_distance = abs(normalized_position.y) - 0.05;
	}
	else
	{
		signed_distance = signed_distance_regular_polygon_edges(normalized_position, polygon_sides);
	}

	float fill_mask = step(signed_distance, 0.0);

	float normalized_outline_thickness = outline_thickness / min_half;
	float outline_mask = step(signed_distance, normalized_outline_thickness) * (1.0 - fill_mask);

	float visible_mask = fill_mask + outline_mask;
	if (visible_mask < 0.5)
		discard;

	COLOR = fill_color * fill_mask + outline_color * outline_mask;
}
