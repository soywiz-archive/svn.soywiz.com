var Memory = function() {
	this.data = {};
};

Memory.prototype.write8 = function(addr, value) {
	this.data[addr + 0] = (value >>  0) & 0xFF;
};

Memory.prototype.write16 = function(addr, value) {
	this.data[addr + 0] = (value >>  0) & 0xFF;
	this.data[addr + 1] = (value >>  8) & 0xFF;
};

Memory.prototype.write32 = function(addr, value) {
	this.data[addr + 0] = (value >>  0) & 0xFF;
	this.data[addr + 1] = (value >>  8) & 0xFF;
	this.data[addr + 2] = (value >> 16) & 0xFF;
	this.data[addr + 3] = (value >> 24) & 0xFF;
};

Memory.prototype.used = function(addr) {
	return (this.data[addr] !== undefined);
};

Memory.prototype.read8 = function(addr) {
	return (this.data[addr + 0] << 0);
};

Memory.prototype.read16 = function(addr) {
	return ((this.data[addr + 0] << 0) | (this.data[addr + 1] << 8));
};

Memory.prototype.read32 = function(addr) {
	return ((this.data[addr + 0] << 0) | (this.data[addr + 1] << 8) | (this.data[addr + 2] << 16) | (this.data[addr + 3] << 24));
};

Memory.align = function(addr, size) {
	if ((addr % size) != 0) addr += size - addr % size;
	return addr;
};
