<?php

$sample = <<<EOF

addi $a0, $0, 1000
jal label

EOF;

	class Value {
	}

	class REG extends Value {
		public $value = 'unknown';
	}

	class Binary extends Value {
	}
	
	class EXP extends Value {
	}

?>