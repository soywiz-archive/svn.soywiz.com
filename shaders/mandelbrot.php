<?php
// Initializes the window.
Screen::title('PHP Mandelbrot explorer');
$screen = Screen::init(512, 512);

// Shortcut for keyboard.
$key = 'Keyboard';

// Creates an empty bitmap to use for vertex for the shader.
$out = new Bitmap($screen->w, $screen->h);

// http://www.opengl.org/registry/doc/GLSLangSpec.Full.1.30.08.pdf
$shader_mandelbrot = new Shader("
	varying vec3 position;
	uniform int maxIterations;
	uniform vec2 center;
	uniform vec4 outerColor1;
	uniform vec4 outerColor2;
	uniform float zoom;

	// http://en.wikipedia.org/wiki/Mandelbrot_set
	void main()
	{
		vec2 z0 = vec2(position) * (1.0 / zoom) + center;
		vec2 z = z0;
		
		for (int iteration = 0; iteration < maxIterations; iteration++)
		{
			z = vec2((z.x * z.x - z.y * z.y + z0.x), (2.0 * z.x * z.y + z0.y));

			if (dot(z, z) >= 4.0) {
				gl_FragColor = mix(outerColor1, outerColor2, float(iteration) / float(maxIterations));
				return;
			}
		}
		
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	}
", "
	varying vec3 position;
	void main()
	{
		position = vec3(gl_TextureMatrix[0] * gl_MultiTexCoord0 - 0.5) * 5.0;
		position.x *= (float({$screen->w}) / float({$screen->h}));
		gl_Position = ftransform();
	}
");

print_r($shader_mandelbrot->params);

// Initial values.
$zoom = 2.2;
list($center_x, $center_y) = array(-0.75, 0);
$maxIterations = 100;

$lastTime = 0;

// Loops until pressing ESC key.
while (!$key::pressed($key::ESC))
{
	// Zoom and maxIterations.
	if ($key::down($key::W    )) $zoom *= 1.03;
	if ($key::down($key::S    )) $zoom /= 1.03;
	if ($key::down($key::A    )) $maxIterations--;
	if ($key::down($key::D    )) $maxIterations++;

	// Limit the iterations.
	Math::clamp($maxIterations, 5, 150);
	// Limit the zoom.
	Math::clamp($zoom, 2.2, 128000);

	// Determines the movement speed.
	$move = 0.1 / $zoom;

	// Desplacement of the center.
	if ($key::down($key::LEFT )) $center_x -= $move;
	if ($key::down($key::RIGHT)) $center_x += $move;
	if ($key::down($key::UP   )) $center_y -= $move;
	if ($key::down($key::DOWN )) $center_y += $move;

	// Limits the position and the zoom.
	Math::clamp($center_x, -2.0, 0.5);
	Math::clamp($center_y, -1.12, 1.12);

	// Print the parameters for the mandelbrot.
	$info = sprintf("Center(%f, %f), Zoom(%.2f), Iterations(%d)", $center_x, $center_y, $zoom, $maxIterations);

	Screen::title('PHP Mandelbrot explorer - ' . $info);
	echo "{$info}\t\r";
	
	$screen->clear();

	// Blits the mandelbrot on the screen.
	$shader_mandelbrot->begin(array(
		'maxIterations' => $maxIterations,
		'center'        => array($center_x, $center_y),
		'outerColor1'   => array(1, 1, 1, 0),
		'outerColor2'   => array(1, 1, 1, 1),
		'zoom'          => $zoom,
	));
	{
		$out->blit($screen, 0, 0, 1, 0, 1);
	}
	$shader_mandelbrot->end();
	//$out->clear(0, 0, 0, 0.5);

	// Input reading. Buffer swap. Clearning new screen.
	Screen::frame();
	timer($lastTime);
}

function timer(&$lastTime, $fps = 60.0) {
	while ((($time = microtime(true)) - $lastTime) < (1.0 / $fps)) usleep(10000);
	$lastTime = $time;
}