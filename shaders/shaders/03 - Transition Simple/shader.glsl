varying vec2 position;
uniform sampler2D src0;
uniform sampler2D src1;

const float pi = 3.14159265358979323846;
uniform int timer;
float transition;
void setTransition() { transition = sin(float(timer) / 50.0 - pi / 2.0) * 0.5 + 0.5; }

void main() {
	setTransition();
	gl_FragColor = mix(
		texture2D(src0, position),
		texture2D(src1, position),
		transition
	);
}