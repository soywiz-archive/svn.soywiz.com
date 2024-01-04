varying vec2 position;
uniform sampler2D src;
uniform sampler2D mask;

const float pi = 3.14159265358979323846;
uniform int timer;
float transition;
void setTransition() { transition = 1.0 - (sin(float(timer) / 50.0 - pi / 2.0) * 0.5 + 0.5); }

void main() {
	setTransition();
	gl_FragColor = texture2D(src, position);
	float alpha = (
		(transition * 2.0 - 1.0) +
		texture2D(mask, position).r
	);
	gl_FragColor.a = clamp(alpha, 0.0, 1.0);
}