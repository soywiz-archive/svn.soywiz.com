// Public Domain

import std.c.windows.windows;
HINSTANCE g_hInst;

extern (C) {
	void gc_init();
	void gc_term();
	void _minit();
	void _moduleCtor();
	void _moduleUnitTests();
}

extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved) {
    switch (ulReason) {
		case DLL_PROCESS_ATTACH:
			gc_init();			// initialize GC
			_minit();			// initialize module list
			_moduleCtor();		// run module constructors
			_moduleUnitTests();		// run module unit tests
		break;
		case DLL_PROCESS_DETACH: gc_term(); break; // shut down GC
		case DLL_THREAD_ATTACH: case DLL_THREAD_DETACH: return false; // Multiple threads not supported yet
		default: break;
    }
    g_hInst=hInstance;
    return true;
}

