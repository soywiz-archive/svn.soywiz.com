<?php
class ComponentSplash extends Component {
	protected $image  = null;
	protected $shader = null;

	protected $radius     = 0.0;
	protected $inc        = 0.002;
	protected $wave       = 0.0;
	protected $waveWidth  = 0.01;
	protected $waveHeight = 0.01;
	
	static public $shader_fragment = "
		varying vec2 position;

		uniform sampler2D src;
		uniform float radius;
		uniform vec2 center;
		uniform float wave;
		uniform vec2 waveSize;

		void main() {
			vec2 dist = position - center;
			vec2 add = vec2(0.0, sin(position.x / waveSize.x + wave) * waveSize.y);

			if (length(dist) >= radius) {
				gl_FragColor = texture2D(src, add + center + normalize(dist) * radius);
			} else {
				gl_FragColor = texture2D(src, add + position);
			}
		}
	";

	static public $shader_vertex = "
		varying vec2 position;

		void main() {
			position = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);
			gl_Position = ftransform();
		}
	";

	function init() {
		$this->image = Bitmap::fromFile(__DIR__ . '/../images/splash.png');
		$this->shader = new Shader(static::$shader_fragment, static::$shader_vertex);
	}

	function draw($screen) {
		$this->shader->begin(array(
			'radius'   => $this->radius,
			'center'   => array(400 / 1024, 300 / 1024),
			'wave'     => $this->wave,
			'waveSize' => array($this->waveWidth, $this->waveHeight),
		));
		{
			$this->image->blit($screen, 0, 0);
		}
		$this->shader->end();
	}
	
	function move() {
		$this->radius += $this->inc;
		$this->inc += 0.00001;
		$this->wave += 0.1;
		$this->waveHeight *= 0.987;
		$this->waveWidth  *= 1.01;
		//echo $this->radius . "\n";
		if ($this->radius >= 1.0) {
			$this->finalize();
		}
	}
	
	function finish() {
		$this->inc = 0;
		$this->radius = 1.00395;
		$this->wave = 29.1;
		list($this->waveWidth, $this->waveHeight) = array(0.18093382763905, 0.00022196854071006);
		$this->finalize();
		echo "finish!\n";
	}
}