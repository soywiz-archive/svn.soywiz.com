varying vec2 position;
uniform sampler2D src;
uniform sampler2D mask;

const vec2 texSize = vec2(310.0, 310.0);
const vec2 increment = 1.0 / texSize;

float size;
const float pi = 3.14159265358979323846;
uniform int timer;
void setTransition() { size = 0.05 + 0.3 * (1.0 - (sin(float(timer) / 50.0 - pi / 2.0) * 0.5 + 0.5)); }

void main() {
	setTransition();
	vec4 col1 = texture2D(src, position);
	vec4 col2 = texture2D(src, position + increment);
	
	if (length(col1 - col2) > size) {
		gl_FragColor = vec4(0, 0, 0, 1);
	} else {
		gl_FragColor = vec4(1, 1, 1, 1);
	}
}