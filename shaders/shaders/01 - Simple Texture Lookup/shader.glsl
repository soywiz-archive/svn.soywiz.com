varying vec2 position;
uniform sampler2D src;

void main() {
	gl_FragColor = texture2D(src, position);
}