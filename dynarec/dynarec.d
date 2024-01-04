import std.stdio, std.string, std.file, std.path, std.c.stdlib, std.c.stdio, std.math;
import std.c.windows.windows;

enum REG4 {
	EAX = 0b000, ECX = 0b001, EDX = 0b010, EBX = 0b011,
	ESP = 0b100, EBP = 0b101, ESI = 0b110, EDI = 0b111
}

extern(Windows) {
	void Sleep(uint);
	uint GetTickCount();
	uint QueryPerformanceCounter(ulong *lpPerformanceCount);
	uint QueryPerformanceFrequency(ulong *lpFrequency);
}

ulong qpfreqv; static this() { QueryPerformanceFrequency(&qpfreqv);	 }

ulong getMilli() {
	ulong v;
	QueryPerformanceCounter(&v);
	return v * 1000 / qpfreqv;
}


// TST27

// Clase que se encarga de la emulación de un TST27
// procesador inventado para esta demostración
class TST27 {
	// Banco de registros
	// Usaremos EBX para almacenar la dirección de los registros
	static uint regs[32];
	static bool stopped = false;
	
	// Memoria
	// Usaremos ECX para almacenar la dirección de la memoria
	static ubyte mem[0x1000];
	
	static ubyte* pc;
	
	static void write1(ubyte  v) { *cast(ubyte *)pc = v; pc += 1; }
	static void write2(ushort v) { *cast(short *)pc = v; pc += 2; }
	static void write4(uint   v) { *cast(int   *)pc = v; pc += 4; }	
	
	void dump_regs() {
		for (int n = 0; n < 32; n++) {
			printf("$%02d = %08X\n", n, regs[n]);
		}
	}
	
	extern(C) void break_execution() {
		dump_regs();
		
		//stopped = true; while (stopped) Sleep(1);
	
		printf("Fin de ejecución");
		exit(-1);
	}
	
	extern(C) static void print_reg(ubyte r) {
		if (r > 23) {
			printf("  \n");
		} else {
			printf("  r%02d = %08X\n", r, TST27.regs[r]);
		}			
	}
	
	// Escribe las instrucciones en código máquina de este procesador
	void SET(ubyte r, uint value) { write1(0x00); write1(r); write4(value); }	
	void ADD(ubyte r1, ubyte r2)  { write1(0x01); write1(r1); write1(r2); }
	void JLT(ubyte r1, ubyte r2, uint addr)  { write1(0x02); write1(r1); write1(r2); write4(addr); }
	void PRINT(ubyte r)           { write1(0x03); write1(r); }
	void END()                    { write1(0x04); }
	
	// Obtiene la dirección de memoria de la instrucción actual
	uint label() { return pc - mem.ptr; }
	
	void clear() {
		for (int n = 0; n < mem.length; n++) mem[n] = 0x00;
		pc = mem.ptr;
	}
	
	// Inicializa la memoria con las instrucciones
	void init(int r = 0) {
		clear();

		void test1() {		
			uint l;
			
			SET(0, 0x00000000);
			SET(1, 0x01FFFFFF);
			SET(2, 0x00000001);
			
			PRINT(0);
			PRINT(1);
			PRINT(2);
			
			PRINT(24);
			
			l = label();
			ADD(0, 2);
			JLT(0, 1, l);
			
			PRINT(0);
			PRINT(1);
			PRINT(2);
	
			END();
		}
		
		void test2() {
			uint l1, l2;
			
			SET(1, 0x00FFFFFF);
			SET(2, 0x00000001);
			
			SET(10, 0x00000000);
			SET(11, 0x00000005);
			
			PRINT(0);
			PRINT(1);
			PRINT(2);
			PRINT(10);
			PRINT(11);
			
			PRINT(24);
			
			l1 = label();
			ADD(10, 2);
			SET(0, 0x00000000);
			l2 = label();
			ADD(0, 2);
			JLT(0, 1, l2);
			JLT(10, 11, l1);
			
			PRINT(0);
			PRINT(1);
			PRINT(2);			
			PRINT(10);
			PRINT(11);
			
			END();
		}
		
		auto funcs = [&test1, &test2];
		writefln("PTR: %08X\n", cast(uint)cast(void *)funcs[r]);
		funcs[r]();
		
		//test1();
		//test2();
		
		pc = mem.ptr;
	}
	
	// Ejecutamos el código interpretando
	void run_int() {
		while (true) {
			ubyte op = *pc; 
			switch (op) {
				case 0x00: // SET - Da un valor 32 bits
					regs[*(pc + 1)] = *cast(uint *)(pc + 2);
					pc += 6;
				break;
				case 0x01: // ADD - Añade a un registro otro
					regs[*(pc + 1)] += regs[*(pc + 2)];
					pc += 3;
				break;
				case 0x02: // JLT - Salta si el primer registro es menor que el segundo
					if (regs[*(pc + 1)] < regs[*(pc + 2)]) {
						pc = mem.ptr + *cast(uint *)(pc + 3);
					} else {
						pc += 7;
					}
				break;
				case 0x03: // PRINT - Imprime un registro por pantalla
					print_reg(*(pc + 1));
					pc += 2;
				break;
				case 0x04: // END - Termina la ejecución del programa
					return;
				break;
			}
		}
	}
	
	// Ejecutamos el código con recompilación dinámica
	void run_dyna() {
		Dyna8086 dyna = new Dyna8086;
			
		void recompile_dir(ubyte* pc) {
			dyna.set_active();
			bool end = false;
			while (!end) {
				ubyte op = *pc; 
				
				// Cargamos la dirección del banco de registros en EBX
				Dyna.MOV4(REG4.EBX, cast(uint)regs.ptr);
			
				// Cargamos la dirección del banco de la memoria
				Dyna.MOV4(REG4.ECX, cast(uint)mem.ptr);
				
				Dyna.label(pc - mem.ptr);
				
				switch (op) {
					case 0x00: // SET - Da un valor 32 bits						
						Dyna.MOV4(REG4.EAX, *cast(uint *)(pc + 2));
						Dyna.VMR_SET(*(pc + 1));
						pc += 6;
					break;
					case 0x01: // ADD - Añade a un registro otro
						// TODO: damos por sentado que r2 vale 1
						Dyna.VMR_INC(*(pc + 1));
						pc += 3;
					break;
					case 0x02: // JLT - Salta si el primer registro es menor que el segundo
						Dyna.VMR_GET(*(pc + 2));
						Dyna.VMR_CMPL(*(pc + 1), REG4.EAX);
						Dyna.JLL(*cast(uint *)(pc + 3));
						pc += 7;
					break;
					case 0x03: // PRINT - Imprime un registro por pantalla
						Dyna.INVOKE_STDCALL(cast(void *)&print_reg, [*(pc + 1)]);
						pc += 2;
					break;
					case 0x04: // END - Termina la ejecución del programa						
						Dyna.RET();
						end = true;
					break;
				}
			}
			
			// 		
		}
				
		recompile_dir(pc);
		
		dyna.run();
	}
	
	void run_native(int r = 0) {
		if (r == 0) {
			regs[0] = 0x00000000;
			regs[1] = 0x00FFFFFF;
			regs[2] = 0x00000001;
			
			print_reg(0);
			print_reg(1);
			print_reg(2);
			
			print_reg(24);
				
			do {
				regs[0] += regs[2];
			} while (regs[0] < regs[1]);				
			
			print_reg(0);
			print_reg(1);
			print_reg(2);
		} else {
			regs[1] = 0x00FFFFFF;
			regs[2] = 0x00000001;
			regs[10] = 0x00000000;
			regs[11] = 0x00000005;
			
			print_reg(0);
			print_reg(1);
			print_reg(2);
			print_reg(10);
			print_reg(11);
			
			print_reg(24);
	
			do {
				regs[10] += regs[2];
				regs[0] = 0x00000000;
				do {
					regs[0] += regs[2];
				} while (regs[0] < regs[1]);				
			} while (regs[10] < regs[11]);
			
			print_reg(0);
			print_reg(1);
			print_reg(2);
			print_reg(10);
			print_reg(11);
		}
	}
	
}


alias Dyna8086 Dyna;

class Dyna8086 {
// LABELS //////////
	static void*[uint] labels;	
	static void label(uint v) { labels[v] = pc; }

// BUFFER //////////
	static ubyte *pc;
	
	static void write1(ubyte  v) { *cast(ubyte *)pc = v; pc += 1; }
	static void write2(ushort v) { *cast(short *)pc = v; pc += 2; }
	static void write4(uint   v) { *cast(int   *)pc = v; pc += 4; }
	
	static int rel4(void* p) { return p - pc - 4; }

// OPS /////////////
	
	static void INC   (REG4 r) { write1(0b_01000_000 | r); }
	static void DEC   (REG4 r) { write1(0b_01001_000 | r); }
	
	static void PUSHR4(REG4 r) { write1(0b_01010_000 | r); }
	static void POPR4 (REG4 r) { write1(0b_01011_000 | r); }	

	static void PUSH1 (byte v) { assert(0 != 0); }	
	static void PUSH4 (int  v) {
		if (v > 0xFF) { write1(0b_01101000); write4(v); }
		else          { write1(0b_01101010); write1(v); }
	}
		
	static void POP4  (REG4 r) { write1(0b01011000 | r); }	
	static void MOV4  (REG4 r, int v) { write1(0b_10111_000 | r); write4(v); }

	static void ADD1  (REG4 r, ubyte v) { write1(0b_10000011); write1(0b_11000_000 | r); write1(v); }	
	static void CALL  (REG4 r) { write1(0b_11111111); write1(0b_11010_000 | r); }
	// El puntero a la función es relativo al PC después de decodificar toda la instrucción
	static void CALL  (void* p) { write1(0b_11101000); write4(rel4(p)); }
	static void RET   (int dis = 0) { write1((dis == 0) ? 0b_11000011 : 0b_11000010); }		
	static void JMP   (void* p) {
		// En los 
		if (abs(p - pc + 2) < 127) {			
			write1(0b_01110101);
			write1(p - pc + 1);
			printf("++++ Usando salto corto\n");
		} else {
			write1(0b_11101001);
			write4(rel4(p));
		}
	}
	
	
	static void CMP   (REG4 r1, REG4 r2) {
		// 3B DF
		// 00111011 11011111
		// CMP EBX, EDI
		write1(0b_00111011);
		write1(0b_11_000_000 | r2 | (r1 << 3));
	}
	
	static void JL (void* p) {
		void *npc = pc + 2;
		
		// 0x7F == JG
		
		//if (abs(p - npc) <= 0x7f) {
		if (true) {
			write1(0x7C);
			write1(p - npc);
		} else {
			assert(0 != 0);
		}
	}
	
// MACROS //////////

	// La convencion de windows especifica que los parametros se pasan por pila
	// y la funcion se encarga de quitar los elementos de la pila
	static void INVOKE_WINDOWS(void *p, int[] vs = []) {
		foreach (v; vs) PUSH4(v);
		CALL(p);
	}

	// La convencion stdcall especifica que los parametros se pasan por pila
	// y la funcion que llama se encarga de dejar la pila en su estado original
	static void INVOKE_STDCALL(void *p, int[] vs = []) {
		INVOKE_WINDOWS(p, vs);
		ADD1(REG4.ESP, vs.length * 4);
	}	

	// Salta a una etiqueta especificada
	static void JMPL  (uint l) { JMP(labels[l]); }

	static void JLL(uint l) {
		JL(labels[l]);
	}
	
	static void _VMR_WREG(ubyte r, REG4 rr = REG4.EAX) {
		write1(0b_01_000_011 | (rr << 3)); // [EBX + r8]
		write1(r * 4);
	}
	
	static void VMR_SET  (ubyte r) {
		write1(0x89); _VMR_WREG(r, REG4.EAX); // MOV ..., EAX		
	}

	static void VMR_GET  (ubyte r) {
		write1(0x8B); _VMR_WREG(r, REG4.EAX); // MOV EAX, ...
	}
	
	static void VMR_INC  (ubyte r) {
		write1(0xFF); // INC/DEC ...
		write1(0b_01_000_011); // [EBX + r8] (INC)
		write1(r * 4);		
	}

	static void VMR_DEC  (ubyte r) {
		write1(0xFF); // INC/DEC ...
		write1(0b_01_001_011); // [EBX + r8] (DEC)
		write1(r * 4);		
	}
	
	static void VMR_CMPL  (ubyte r1, REG4 r2) {		
		write1(0b_00111001);
		write1(0b_01_000_011 | (r2 << 3));
		write1(r1 * 4);
	}

	static void VMR_CMPR  (REG4 r1, ubyte r2) {
		write1(0b_00111011);
		write1(0b_01_000_011 | (r1 << 3));
		write1(r2 * 4);
	}
	
	static void BREAK() {//
		//INVOKE_STDCALL(&break_execution);
		exit(-1);
	}
	
// LOCAL ///////////
	
	static ubyte *local_pc;
	ubyte[] data;
	
	this() { data = new ubyte[0x1000]; local_pc = &data[0]; }	
	void set_active() { pc = local_pc; }
	
	void dump() {
		int p = 0;
		while (p < data.length) {
			printf("%06X | ", p);
			for (int n = 0; n < 16; n++, p++) {
				if (n == 8) printf(" ");
				printf("%02X ", data[p]);
			}
			printf("\n");
			if (&data[p] > pc) break;
		}
	}
	
	void run() {
		void *p = data.ptr;
		asm { call p; }
	}
}

void demo1() {
	printf("DEMO1\n");
	static uint regs[32];
	static ubyte mem[0x1000];

	Dyna dyna = new Dyna;
	dyna.set_active();
	
	extern(C) static int test(int a) {
		printf("test:[%d]\n", a);
		return a - 1;
	}
	
	/*
	Dyna.PUSH4(0xFFFFFFFF);
	Dyna.POPR4(REG4.EBX);
	Dyna.PUSHR4(REG4.EAX);
	Dyna.CALL(&test);
	Dyna.POPR4(REG4.EBX);
	Dyna.PUSHR4(REG4.EAX);
	Dyna.CALL(&test);
	Dyna.POPR4(REG4.EBX);
	Dyna.PUSHR4(REG4.EAX);
	Dyna.CALL(&test);
	Dyna.POPR4(REG4.EBX);
	Dyna.PUSHR4(REG4.EAX);
	Dyna.CALL(&test);
	Dyna.POPR4(REG4.EBX);
	Dyna.PUSHR4(REG4.EAX);
	Dyna.POPR4(REG4.EBX);
	*/	
	
	/*
	Dyna.PUSH4(0xFFFFFFFF);
	Dyna.INC(REG4.EAX);
	*/

	// Cargamos la dirección del banco de registros en EBX
	Dyna.MOV4(REG4.EBX, cast(uint)regs.ptr);

	// Cargamos la dirección del banco de la memoria
	Dyna.MOV4(REG4.ECX, cast(uint)mem.ptr);
		
	
	/*
	Dyna.MOV4(REG4.EAX, 10);
	Dyna.WREG(0);
	*/
	
	Dyna.VMR_GET(0);
	Dyna.PUSHR4(REG4.EAX);
	Dyna.CALL(&test);
	Dyna.ADD1(REG4.ESP, 4);
	

	//Dyna.MOV4(REG4.EDX, 0x6FFFFFFF);
	Dyna.MOV4(REG4.EDX, 0x00FFFFFF);
	Dyna.label(1);		
	Dyna.VMR_INC(0);
	Dyna.VMR_CMPL(0, REG4.EDX);
	Dyna.JLL(1);

	//
	Dyna.VMR_GET(0);
	Dyna.PUSHR4(REG4.EAX);
	Dyna.CALL(&test);
	Dyna.ADD1(REG4.ESP, 4);
	
	//Dyna.BREAK();
	
	//Dyna.JMPL(1);
	
	/*	
	Dyna.label(1);	
	Dyna.INVOKE_STDCALL(&test, [1]);
	Dyna.INVOKE_STDCALL(&test, [2]);
	Dyna.JMPL(1);
	*/
	
	
	Dyna.RET();	
	
	dyna.run();
	
	dyna.dump();	
	
	printf("\n\n");
}

void demo2(int r = 0) {
	uint start;
	int intt = 0, dynat = 0, nativ = 0;
	TST27 cpu = new TST27();
	
	printf("DEMO2 (%d)\n", r);
	
	if (true) {
	//if (false) {
		writefln("Ejecutando programa interpretado: {");
		cpu.init(r);
		start = getMilli();
		cpu.run_int();
		intt = getMilli() - start;
		writefln("} TIEMPO: %d ms\n", intt);
	}
	
	if (true) {
		writefln("Ejecutando programa con recompilación dinámica:");
		cpu.init(r);
		start = getMilli();
		cpu.run_dyna();
		dynat = getMilli() - start;
		writefln("} TIEMPO: %d ms\n", dynat);
	}

	if (true)	 {
		writefln("Ejecutando programa nativo:");
		cpu.init(r);
		start = getMilli();
		cpu.run_native(r);
		nativ = getMilli() - start;
		writefln("} TIEMPO: %d ms\n", nativ);		
	}
	
	writefln("DYNA: La mejora ha sido de un: %.2f%% (%.1f veces mas rápido)", cast(real)intt * 100 / cast(real)dynat, (cast(real)intt / cast(real)dynat));
	writefln("NATI: La mejora ha sido de un: %.2f%% (%.1f veces mas rápido)", cast(real)intt * 100 / cast(real)nativ, (cast(real)intt / cast(real)nativ));
}

int main(char[][] args) {
	demo1();
	demo2(0);
	demo2(1);
	
	return 0;
}
