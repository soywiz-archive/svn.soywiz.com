<?php
class ComponentMain extends Component {
	protected $image_bg   = null;
	protected $transition = null;
	protected $header     = null;
	protected $page       = null;

	protected $shader     = null;
	
	protected $pages      = array();
	protected $pageIdx    = 0;
	
	protected $timerInit  = 0;
	
	static public $shader_fragment = "
		varying vec2 position;
		uniform sampler2D src;
		uniform sampler2D mask;
		uniform float transition;

		void main() {
			gl_FragColor = texture2D(src, position);
			gl_FragColor.a = clamp((
				(transition * 2.0 - 1.0) +
				texture2D(mask, position).r
			), 0.0, 1.0);
		}
	";
	
	function loadPages() {
		$this->pages = array();
		foreach (scandir(__DIR__ . '/../shaders') as $page) {
			if ($page[0] == '.') continue;
			$this->pages[] = $page;
		}
		print_r($this->pages);
	}
	
	function changePage($pageIdx) {
		$this->pageIdx = $pageIdx;
		Math::clamp(0, count($this->pages) - 1, $this->pageIdx);
		$this->page->loadPage($this->pages[$this->pageIdx]);
	}

	function changePageInc($pageInc) {
		$this->changePage($this->pageIdx + $pageInc);
	}
	
	function init() {
		$this->image_bg   = Bitmap::fromFile(__DIR__ . '/../images/background.png');
		$this->transition = Bitmap::fromFile(__DIR__ . '/../images/full_transition.png');
		$this->shader     = new Shader(static::$shader_fragment, ComponentSplash::$shader_vertex);

		$this->header     = new ComponentMainHeader();
		$this->page       = new ComponentPage();
		$this->font       = Font::fromName("Lucida Console", 18);
		$this->header->title = &$this->page->title;

		$this->loadPages();
		$this->changePage(0);
	}
	
	function input() {
		if (Keyboard::pressed(Keyboard::LEFT )) $this->changePageInc(-1);
		if (Keyboard::pressed(Keyboard::RIGHT)) $this->changePageInc(+1);
	}

	function draw($screen) {
		$this->image_bg->blit($screen);
		$this->header->draw($screen);
		$this->page->draw($screen);
		
		if ((Component::$back !== null) && ($this->timerInit <= 120)) {
			@$this->shader->begin(array(
				'src'  => self::$back,
				'mask' => $this->transition,
				'transition' => 1.0 - $this->timerInit / 120,
			));
			{
				self::$back->blit($screen);
			}
			$this->shader->end();
		}
	}
	
	function move() {
		if ($this->timerInit < 120) $this->timerInit++;
		$this->header->move();
		$this->page->move();
	}
}