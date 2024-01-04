varying vec2 position;
uniform sampler2D src;

// http://en.wikipedia.org/wiki/Gaussian_blur
// 1 PASS and calculating all the time.
// It could be make in two passes or precalculating in a matrix the values or so.
vec4 gaussian(image4 img, float2 coord, float mm) {
	float mm2 = 2.0 * mm * mm;
	float pi_mm = (1.0 / (PI * mm2));
	float sum = 0.0;
	for (int y = -3; y <= 3; y++) {
		for (int x = -3; x <= 3; x++) {
			sum += pi_mm * exp(-(float(x*x + y*y) / mm2));
		}
	}
	float4 ret = float4(0, 0, 0, 0);
	for (int y = -3; y <= 3; y++) {
		for (int x = -3; x <= 3; x++) {
			float g = pi_mm * exp(-(float(x*x + y*y) / mm2)) / sum;
			ret += sampleNearest(img, coord) * g;
			if (x == 0 && y == 0) {
			} else {
				ret += sampleNearest(img, coord + float2(+x, +y)) * g;
				ret += sampleNearest(img, coord + float2(-x, -y)) * g;
				if (x != 0) ret += sampleNearest(img, coord + float2(-x, +y)) * g;
				if (y != 0) ret += sampleNearest(img, coord + float2(+x, -y)) * g;
			}
			//float2(x, y);
		}
	}
	return pixel4(ret);
}


void main() {
	gl_FragColor = texture2D(src, position);
}

input image4 src;
output float4 result;

parameter float mm
<
	minValue : 0.42;
	maxValue : 2.8;
	defaultValue : 0.42;
>;


void evaluatePixel()
{
   result = gaussian(src, outCoord(), mm);
}