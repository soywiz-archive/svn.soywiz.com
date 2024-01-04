var Labels = function() {
	this.data = {};
};

Labels.prototype.add = function(name, value) {
	this.data['.' + name] = value;
};

Labels.prototype.get = function(name) {
	return this.data['.' + name];
};

Labels.prototype.remove = function(name) {
	this.data['.' + name] = null;
};