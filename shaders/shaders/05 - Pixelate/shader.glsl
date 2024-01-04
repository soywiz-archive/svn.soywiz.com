varying vec2 position;
uniform sampler2D src;
uniform sampler2D mask;

float size;
const float pi = 3.14159265358979323846;
uniform int timer;
void setTransition() { size = 0.1 - 0.1 * (1.0 - (sin(float(timer) / 50.0 - pi / 2.0) * 0.5 + 0.5)); }

void main() {
	setTransition();
	gl_FragColor = texture2D(
		src,
		floor(position / size) * size
	);
}