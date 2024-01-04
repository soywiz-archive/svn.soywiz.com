<?php
error_reporting(E_ALL | E_STRICT);

// Initializes the window.
Screen::title('Presentación de Shaders');
$screen = Screen::init(800, 600);

function __autoload($class) {
	$file = __DIR__ . '/classes/' . basename($class) . '.php';
	if (file_exists($file)) {
		require_once($file);
	} else {
		throw(new Exception("File '{$file}' doesn't exists."));
	}
}

if (!in_array('test', $argv)) {
	ComponentSplash::createAndLoop();
} else {
	Component::$back = null;
}

ComponentMain::createAndLoop();
