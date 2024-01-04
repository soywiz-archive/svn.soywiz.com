varying vec2 position;
uniform sampler2D src;

void main() {
	vec4 white = vec4(1, 1, 1, 1);
	vec4 color = texture2D(src, position);
	gl_FragColor.rgb = white.rgb - color.rgb;
	gl_FragColor.a = 1.0;
}
