var MIPS = function() {
	this.reset();
};

MIPS.prototype.reset = function() {
	this.memory = new Memory();
	this.labels = new Labels();
	this.wpos = 0;
};

MIPS.registerNames = [
	"zero", "at",   "v0",   "v1",   "a0",   "a1",   "a2",   "a3",
	"t0",   "t1",   "t2",   "t3",   "t4",   "t5",   "t6",   "t7",
	"s0",   "s1",   "s2",   "s3",   "s4",   "s5",   "s6",   "s7",
	"t8",   "t9",   "k0",   "k1",   "gp",   "sp",   "s8",   "ra",
];

MIPS.r_registerNames = {};
for (var n = 0; n < 32; n++) MIPS.r_registerNames[MIPS.registerNames[n]] = n;

/*MIPS.func_op0 = [
	'sll' , null   , 'srl' , 'sra' , 'sllv'   , null   , 'srlv', 'srav', 'jr'  , 'jalr' , null  , null  , 'syscall', 'break', null  , null  ,
	'mfhi', 'mthi' , 'mflo', 'mtlo', null     , null   , null  , null  , 'mult', 'multu', 'div' , 'divu', null     , null   , null  , null  ,
	'add' , 'addu' , 'sub' , 'subu', 'and'    , 'or'   , 'xor' , 'nor' , null  , null   , 'slt' , 'sltu', null     , null   , null  , null  ,
	null  , null   , null  , null  , null     , null   , null  , null  , null  , null   , null  , null  , null     , null   , null  , null  ,
];*/

MIPS.reg = function(r) {
	r = String(r).trim();	
	
	if (r.substr(0, 1) == '$') r = r.substr(1);	

	if (MIPS.r_registerNames[r] !== undefined) {		
		//alert(MIPS.r_registerNames[r]);
		return MIPS.r_registerNames[r];
	}
	return parseInt(r.substr(1));
};

MIPS.prototype.execute = function() {
};

MIPS.prototype.compileProgram = function(program) {
	program = String(program);	
	var lines = program.split("\n");

	this.reset();

	var errors = [];
	for (var n = 0; n < lines.length; n++) {
		var cerr = this.parseIns(lines[n]);
		if (cerr !== null) errors.push(cerr);
	}
	
	return errors;
};

MIPS.encodeTypeR = function(co, rs, rt, rd, desp, func) {
	//alert(co + ', ' + rs + ', ' + rt + ', ' + rd + ', ' + desp + ', ' + func);
	return (
		((func & 0x3F) <<  0) |
		((desp & 0x1F) <<  6) |
		((rd   & 0x1F) << 11) |
		((rt   & 0x1F) << 16) |
		((rs   & 0x1F) << 21) |
		((co   & 0x3F) << 26) |
	0);
};

MIPS.encodeTypeRr = function(co, rs, rt, rd, desp, func) {
	return MIPS.encodeTypeR(co, MIPS.reg(rs), MIPS.reg(rt), MIPS.reg(rd), desp, func);
};

MIPS.encodeTypeI = function(co, rs, rt, inm) {
	return (
		((inm & 0xFFFF) <<  0) |
		((rt  & 0x1F  ) << 16) |
		((rs  & 0x1F  ) << 21) |
		((co  & 0x3F  ) << 26) |
	0);
};

MIPS.encodeTypeJ = function(co, dest) {
	return (
		((dest & 0x3ffffff) <<  0) |
		((co   & 0x1F     ) << 26) |
	0);
};

MIPS.prototype.parseIns = function(line) {
	var p, label, labeladdr;
	
	line = String(line).trim();
	labeladdr = this.wpos;
	
	// Comprueba si hay algún comentario y lo elimina
	if ((p = line.search('#')) != -1) line = line.substr(0, p).rtrim();
	
	// Comprueba si hay una etiqueta
	if ((p = line.search(':')) != -1) {
		label = line.substr(0, p).trim();		
		line = line.substr(p + 1).ltrim();
	}	
	
	// Separa la instrucción de los parámetros
	var pline = /\s*(\S+)\s*(.*)/.exec(line);	
	if (pline === null) return null;
		
	var inst = pline[1].toLowerCase(); // Instrucción
	var pars = pline[2];               // Parámetros
	
	// Directiva
	if (inst.substr(0, 1) == '.') {
		var direct = inst.substr(1);
		switch (direct) {
			// Define un bloque de datos
			case 'data': case 'text': {
				var addr;
				// Tiene parámetros
				if (pars.length) {					
					addr = pars.toInteger();
				}
				// No tiene parámetros
				else {
					addr = (direct == 'data') ? 0x10000000 : 0x00400000;
				}
				this.wpos = addr;
			} break;
			
			// Otros
			case 'global': case 'globl':
			
			break;
			
			// Datos básicos (enteros)
			case 'byte':
				labeladdr = this.wpos = Memory.align(this.wpos, 1);
				var l = pars.split(',')
				for (var n = 0; n < l.length; n++) {
					this.memory.write8(this.wpos, l[n].toInteger());
					this.wpos += 1;
				}
			break;
			case 'half': case 'halfword':
				labeladdr = this.wpos = Memory.align(this.wpos, 2);
				var l = pars.split(',')
				for (var n = 0; n < l.length; n++) {
					this.memory.write16(this.wpos, l[n].toInteger());
					this.wpos += 2;
				}
			break;
			case 'word':
				labeladdr = this.wpos = Memory.align(this.wpos, 4);
				var l = pars.split(',')
				for (var n = 0; n < l.length; n++) {
					this.memory.write32(this.wpos, l[n].toInteger());
					this.wpos += 4;
				}
			break;

			case 'dword':
			break;

			case 'qword':
			break;
			
			// Datos básicos (coma flotante)
			/*
			case 'float':
				tlabeladdr = Memory.align(this.wpos, 4);
				this.memory.write32(caddr, 0x00000000);
				this.wpos = labeladdr + 4;
			break;
			case 'double':
				labeladdr = Memory.align(this.wpos, 8);
				this.memory.write32(caddr, 0x00000000);
				this.memory.write32(caddr, 0x00000000);
				this.wpos = labeladdr + 8;
			break;
			*/

			// Datos básicos (cadenas/espaciado)
			case 'space':
				this.wpos += pars.toInteger();
			break;
			case 'asciiz':
			case 'ascii':
				labeladdr = this.wpos = Memory.align(this.wpos, 1);
				var str = pars.parseString();
				for (var n = 0; n < str.length; n++) this.memory.write8(this.wpos++, str.charCodeAt(n));
				if (direct == 'asciiz') this.memory.write8(this.wpos++, 0);
			break;
			default:
				return 'Unknown directive "' + direct + '"';
			break;
		}
	}
	else {
		var l = pars.split(','); for (k in l) l[k] = l[k].trim();
		labeladdr = this.wpos = Memory.align(this.wpos, 4);
		var code = 0x00000000;
		
		// rs, rt, rd
		
		switch (inst) {
			case 'add' : code = MIPS.encodeTypeRr(0x00, l[1], l[2], l[0],    0, 0x20); break;
			case 'sub' : code = MIPS.encodeTypeRr(0x00, l[1], l[2], l[0],    0, 0x22); break;
			case 'mult': code = MIPS.encodeTypeRr(0x00, l[0], l[1],    0,    0, 0x18); break;
			case 'div' : code = MIPS.encodeTypeRr(0x00, l[0], l[1],    0,    0, 0x1A); break;

			case 'and' : code = MIPS.encodeTypeRr(0x00, l[1], l[2], l[0],    0, 0x24); break;
			case 'or'  : code = MIPS.encodeTypeRr(0x00, l[1], l[2], l[0],    0, 0x25); break;
			case 'xor' : code = MIPS.encodeTypeRr(0x00, l[1], l[2], l[0],    0, 0x26); break;
			case 'nor' : code = MIPS.encodeTypeRr(0x00, l[1], l[2], l[0],    0, 0x27); break;

			case 'mfhi': code = MIPS.encodeTypeRr(0x00,    0,    0, l[0],    0, 0x10); break;
			case 'mthi': code = MIPS.encodeTypeRr(0x00,    0,    0, l[0],    0, 0x11); break;
			case 'mflo': code = MIPS.encodeTypeRr(0x00,    0,    0, l[0],    0, 0x12); break;
			case 'mtlo': code = MIPS.encodeTypeRr(0x00,    0,    0, l[0],    0, 0x13); break;

			case 'slt' : code = MIPS.encodeTypeRr(0x00, l[0], l[1], l[2],    0, 0x2a); break;

			case 'jr'  : code = MIPS.encodeTypeRr(0x00, l[0],    0,    0,    0, 0x08); break;

			case 'sll' : code = MIPS.encodeTypeRr(0x00,    0, l[1], l[0], l[2], 0x00); break;
			case 'srl' : code = MIPS.encodeTypeRr(0x00,    0, l[1], l[0], l[2], 0x02); break;
			
			default:
				return 'Unknown instruction "' + inst + '"';
			break;
		}
		this.memory.write32(this.wpos, code);
		this.wpos += 4;
	}
	
	if (label !== undefined) this.labels.add(label, labeladdr);
	
	//alert(line);
	return null;
};

// Desensambla una instrucción MIPS con los 32 bits del
// código de instrucción y el contador de programa.
MIPS.disassemble = function(pc, code) {
};