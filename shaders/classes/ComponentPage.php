<?php
class ComponentPage extends Component {
	protected $source     = '';
	protected $lastSource = '';
	protected $shader     = null;

	// Images.
	protected $source_bg  = null;
	protected $overlaySrc = null;
	protected $frame      = null;
	protected $images     = array();
	
	protected $font       = null;

	protected $page       = null;
	protected $timer      = 0;
	protected $timer2     = 0;
	public    $title      = 'Page Title';

	static public $shader_vertex = "
		varying vec2 position;

		void main() {
			position = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);
			gl_Position = ftransform();
		}
	";

	function init() {
		$this->frame      = Bitmap::fromFile(__DIR__ . '/../images/frame.png');
		$this->source_bg  = Bitmap::fromFile(__DIR__ . '/../images/source_bg.png');
		$this->overlaySrc = new Bitmap($this->source_bg->w, $this->source_bg->h); $this->overlaySrc->clear();
		$this->font       = Font::fromName("Lucida Console", 17);
		$this->images     = array(
			0 => Bitmap::fromFile(__DIR__ . '/../images/kannagi.png'),
			1 => Bitmap::fromFile(__DIR__ . '/../images/rin.png'),
			2 => Bitmap::fromFile(__DIR__ . '/../images/mask.png'),
			3 => Bitmap::fromFile(__DIR__ . '/../images/depthMask.png'),
		);
	}

	function loadPage($page) {
		if ($page === $this->page) return; else $this->page = $page;
		echo "Page changed: '{$page}'\n";
		$path = __DIR__ . '/../shaders/' . basename($page);
		$this->title  = $page;
		if (file_exists("{$path}/title.txt")) {
			$this->title  = file_get_contents("{$path}/title.txt");
		}
		$this->shader = null;
		@$shader_text = file_get_contents("{$path}/shader.glsl");
		if (strlen($shader_text)) $this->shader = new Shader($shader_text, static::$shader_vertex);
		try {
			$this->overlay = Bitmap::fromFile("{$path}/overlay.png");
		} catch (Exception $e) {
			$this->overlay = new Bitmap(800, 600);
			$this->overlay->clear();
		}
		//echo $shader_text;
		@$this->source = file_get_contents("{$path}/source.txt");
		$this->source = strtr(
			$this->source,
			array(
				"\r" => '',
				"\t" => '   ',
			)
		);
		$this->timer = 0;
	}
	
	function draw($screen) {
		if (strlen($this->source)) {
			$this->source_bg->blit($screen, 32 - 16, 128 - 16, 1.0, 0, 0.7);
			$this->overlaySrc->blit($screen, 32, 128);
		}

		if ($this->shader !== null) {
			$this->frame->blit($screen, 470 - 11, 118 - 11, 1.0, 0, 0.5 + sin($this->timer2 / 60.0) * 0.2);
			if ($this->shader !== null) {
				$params = array(
					'src0'      => $this->images[0],
					'src1'      => $this->images[1],
					'mask'      => $this->images[2],
					'depthMask' => $this->images[3],
					'timer'     => $this->timer,
				);
				//echo "{$this->timer}\n";
				//$params['transition'] = 0.5;
				@$this->shader->begin($params);
			}
			{
				$this->images[0]->blit($screen, 470, 118);
			}
			if ($this->shader !== null) $this->shader->end();
		}
		
		$this->overlay->blit($screen, 0, 0);
	}
	
	function move() {
		$this->timer++;
		$this->timer2++;
		if ($this->source != $this->lastSource) {
			$this->lastSource = $this->source;
			$text = &$this->source;
			$this->overlaySrc->clear();
			$this->font->blit($this->overlaySrc, $text, 0 + 1, 0 + 1, array(1, 1, 1, 0.2));
			$this->font->blit($this->overlaySrc, $text, 0 - 1, 0 + 1, array(1, 1, 1, 0.2));
			$this->font->blit($this->overlaySrc, $text, 0 + 1, 0 - 1, array(1, 1, 1, 0.2));
			$this->font->blit($this->overlaySrc, $text, 0 - 1, 0 - 1, array(1, 1, 1, 0.2));
			$this->font->blit($this->overlaySrc, $text, 0 + 0, 0 + 0, array(0, 0, 0, 1.0));
		}
	}
}