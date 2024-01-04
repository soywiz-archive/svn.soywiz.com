varying vec2 position;
uniform sampler2D src;

void main() {
	gl_FragColor.rgba = texture2D(src, position).bbba * vec4(1.0, 0.5, 0.0, 1.0);
}
