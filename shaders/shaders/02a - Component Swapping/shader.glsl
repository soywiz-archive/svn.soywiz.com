varying vec2 position;
uniform sampler2D src;

void main() {
	gl_FragColor.rgb = (
		texture2D(src, position).gbr
	);
	gl_FragColor.a = 0.7;
}