<?php
class ComponentMainHeader extends Component {
	protected $image       = null;
	protected $image_title = null;
	protected $shader      = null;
	protected $font        = null;
	protected $overlay     = null;

	protected $timer = 0;
	
	public $title = 'Section title';
	public $lastTitle = '';

	static public $shader_fragment = "
		varying vec2 position;
		uniform vec2 texSize;
		uniform float timer;

		void main() {
			vec2 test = vec2(0.2, 0.08);
			float border = 6.0;
			float dist = texSize.y * (1.0 - test.y) + (sin((position.x + timer / 3.0) / 20.0) * texSize.y * (test.y + sin((position.x / 4.0 + timer) / 50.0) * 0.02)) - border;
			gl_FragColor = vec4(1);
			gl_FragColor.a = 0.9;
			if (position.y >= dist) {
				gl_FragColor *= 1.0 - (position.y - dist) / border;
			}
		}
	";

	function init() {
		$this->image       = new Bitmap(800, 90);
		$this->overlay     = new Bitmap(800, 90);
		$this->image_title = Bitmap::fromFile(__DIR__ . '/../images/text_shaders.png');
		$this->shader      = new Shader(static::$shader_fragment, static::$shader_vertex);
		$this->font        = Font::fromName('Verdana', 32);
	}

	function draw($screen) {
		$this->shader->begin(array(
			'texSize' => array($this->image->w, $this->image->h),
			'timer'   => $this->timer,
		));
		{
			$this->image->blit($screen);
		}
		$this->shader->end();

		$this->overlay->blit($screen);
	}
	
	function move() {
		$this->timer++;

		if ($this->lastTitle != $this->title) {
			$this->lastTitle = $this->title;
			$this->overlay->clear();
			$this->image_title->blit($this->overlay, 16, 10, 0.5);
			$this->font->blit($this->overlay, $this->title, 256 - 1, 16 - 1, array(0, 0, 0, 0.8));
			$this->font->blit($this->overlay, $this->title, 256 + 1, 16 - 1, array(0, 0, 0, 0.8));
			$this->font->blit($this->overlay, $this->title, 256 - 1, 16 + 1, array(0, 0, 0, 0.8));
			$this->font->blit($this->overlay, $this->title, 256 + 1, 16 + 1, array(0, 0, 0, 0.8));
			$this->font->blit($this->overlay, $this->title, 256 + 0, 16 + 0, array(1, 1, 1, 1));
		}
	}
}
