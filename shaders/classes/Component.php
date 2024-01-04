<?php
abstract class Component {
	static public $shader_fragment = "
		void main() {
			gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
		}
	";
	
	static public $shader_vertex = "
		varying vec2 position;

		void main() {
			position = vec2(gl_MultiTexCoord0);
			gl_Position = ftransform();
		}
	";
	
	static public $back = null;

	function __construct() { $this->init(); }
	function init() { }
	function input() { }
	function draw($screen) { }
	function move() { }
	function finish() { }

	// Finalizing.
	private $finalized = false;
	public function finalized() { return $this->finalized; }
	protected function finalize() { $this->finalized = true; }
	
	static protected function timer(&$lastTime, $fps = 60.0) {
		while ((($time = microtime(true)) - $lastTime) < (1.0 / $fps)) usleep(10000);
		$lastTime = $time;
	}
	
	public function loop() {
		$timer = 0;
		while (!$this->finalized() && !Keyboard::pressed(Keyboard::ESC)) {
			//if (Keyboard::pressed(Keyboard::F)) $GLOBALS['screen'] = Screen::init(800, 600, true);
			$this->input();
			$this->move();
			$this->draw($GLOBALS['screen']);
			Screen::frame();
			static::timer($timer);
		}
		$this->finish();
		self::$back = new Bitmap(800, 600);
		$temp = new Bitmap(800, 602);
		//$GLOBALS['screen']->blit(self::$back);
		$this->draw($temp);
		$temp->blit(self::$back, 0, -2);
		$this->draw($GLOBALS['screen']);
		
		Screen::frame();
	}
	
	static public function createAndLoop() {
		$obj = new static();
		$obj->loop();
	}
}