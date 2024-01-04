String.prototype.ltrim = function() {
	return this.replace(/^\s+/, '');
};

String.prototype.rtrim = function() {
	return this.replace(/\s+$/, '');
};

String.prototype.trim = function() {
	return this.ltrim().rtrim();
};

String.prototype.toInteger = function() {
	var str = this, radix = 10;
	if (str.substr(0, 1) == '\'') return str.charCodeAt(1);
	if (str.substr(0, 1) == '0') {		
		switch (this.substr(1, 1)) {			
			case 'x': radix = 16; str = this.substr(2); break; // Hexadecimal
			case 'b': radix =  2; str = this.substr(2); break; // Binary
			default:  radix =  8; str = this.substr(1); break; // Octal
		}
	}
	return parseInt(str, radix);
};

String.prototype.parseString = function() {
	eval('var v = ' + this + ';');
	return v;
};

Number.prototype.toHex = function(padding) {
	var h = '0123456789ABCDEF', r = '', n = (this >= 0) ? this : -this;
	while (n) { r = h.substr(n % 16, 1) + r; n = Math.floor(n / 16); }
	while (r.length < padding) r = '0' + r;		
	if (this < 0) r = '-' + r;
	return r;
};