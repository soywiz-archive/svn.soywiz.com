varying vec2 position;
uniform sampler2D src;

vec2 center = vec2(-1.5, -0.0);
vec2 add = vec2(0.0, -0.3);
const int maxIterations = 50;
const vec4 outerColor1 = vec4(0, 0, 0, 0);
const vec4 outerColor2 = vec4(0, 0, 0, 1);
float zoom = 0.4; // 0.25-10.0

const float pi = 3.14159265358979323846;
uniform int timer;
void setTransition() {
	float transition = (sin(float(timer) / 50.0 - pi / 2.0) * 0.5 + 0.5);
	zoom = 0.25 + 100.0 * transition;
	//center = vec2(-2.0, -0.75 + transition);
}

void main() {
	setTransition();
	vec2 z0 = (position / vec2(1.0, 1.0)) * (1.0 / zoom) + center + (add / zoom);
	vec2 z = z0;
					
	gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	for (int iteration = 0; iteration < maxIterations; iteration++)
	{
		z = vec2((z.x * z.x - z.y * z.y + z0.x), (2.0 * z.x * z.y + z0.y));

		if (dot(z, z) >= 4.0) {
			gl_FragColor = mix(outerColor1, outerColor2, float(iteration) / float(maxIterations));
			break;
		}
	}
}
