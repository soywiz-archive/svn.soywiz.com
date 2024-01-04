varying vec2 position;
uniform sampler2D src;

const vec2 texSize = vec2(310.0, 310.0);
const vec2 increment = 1.0 / texSize;

float mm;
const float pi = 3.14159265358979323846;
uniform int timer;
void setTransition() {
	mm = 0.3 + 2.6 * (sin(float(timer) / 50.0 - pi / 2.0) * 0.5 + 0.5);
	//mm = 0.8;
}

//#define gaussian gaussianSlowest
#define gaussian gaussianSlow

// http://en.wikipedia.org/wiki/Gaussian_blur
vec4 gaussianSlowest(sampler2D img, vec2 coord, float mm) {
	float mm2 = 2.0 * mm * mm;
	float pi_mm = (1.0 / (pi * mm2));

	float sum = 0.0;
	vec4 ret = vec4(0);
	for (int pass = 0; pass < 2; pass++) {
		for (int y = -3; y <= 3; y++) {
			for (int x = -3; x <= 3; x++) {
				float g = pi_mm * exp(-(float(x*x + y*y) / mm2));
				if (pass == 0) {
					sum += g;
				} else {
					ret += texture2D(img, coord + increment * vec2(x, y)) * g / sum;
				}
			}
		}
	}
	return vec4(ret);
}

vec4 gaussianSlow(sampler2D img, vec2 coord, float mm) {
	float mm2 = 2.0 * mm * mm;
	float pi_mm = (1.0 / (pi * mm2));
	
	// Sum.
	float sum = 0.0; for (int y = 0; y <= 3; y++) for (int x = 0; x <= 3; x++) {
		sum += pi_mm * exp(-(float(x*x + y*y) / mm2)) * (1.0 + float(x != 0 || y != 0) + float(x != 0) + float(y != 0));
	}
	
	vec4 ret = vec4(0);
	for (int y = 0; y <= 3; y++) {
		for (int x = 0; x <= 3; x++) {
			float g = pi_mm * exp(-(float(x*x + y*y) / mm2)) / sum;
			if (x == 0 && y == 0) {
				ret += texture2D(img, coord) * g;
			} else {
				ret += texture2D(img, coord + float2(+x, +y) * increment) * g;
				ret += texture2D(img, coord + float2(-x, -y) * increment) * g;
				if (x != 0) ret += texture2D(img, coord + float2(-x, +y) * increment) * g;
				if (y != 0) ret += texture2D(img, coord + float2(+x, -y) * increment) * g;
			}
			//float2(x, y);
		}
	}
	return vec4(ret);
}

void main() {
	setTransition();
	gl_FragColor = gaussian(src, position, mm);
}
