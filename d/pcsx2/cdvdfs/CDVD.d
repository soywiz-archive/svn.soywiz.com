module cdvdfs;

import isofs;

import std.stdio;
import std.string;
import std.stream;
import std.file;

// CDVDreadTrack mode values:

enum CDVD_MODE : int {
	M_2352 = 0, // full 2352 bytes
	M_2340 = 1, // skip sync (12) bytes
	M_2328 = 2, // skip sync+head+sub (24) bytes
	M_2048 = 3, // skip sync+head+sub (24) bytes
	M_2368 = 4, // full 2352 bytes + 16 subq
}

// CDVDgetDiskType returns:
enum CDVD_TYPE : int {
	ILLEGAL   = 0xff, // Illegal Disc
	DVDV      = 0xfe, // DVD Video
	CDDA      = 0xfd, // Audio CD
	PS2DVD    = 0x14, // PS2 DVD
	PS2CDDA   = 0x13, // PS2 CD (with audio)
	PS2CD     = 0x12, // PS2 CD
	PSCDDA    = 0x11, // PS CD (with audio)
	PSCD      = 0x10, // PS CD
	UNKNOWN   = 0x05, // Unknown
	DETCTDVDD = 0x04, // Detecting Dvd Dual Sided
	DETCTDVDS = 0x03, // Detecting Dvd Single Sided
	DETCTCD   = 0x02, // Detecting Cd
	DETCT     = 0x01, // Detecting
	NODISC    = 0x00, // No Disc
}

// CDVDgetTrayStatus returns:
enum CDVD_TRAY : int {
	CLOSE = 0x00,
	OPEN  = 0x01
}

// cdvdTD.type (track types for cds)
const int CDVD_AUDIO_TRACK = 0x01;
const int CDVD_MODE1_TRACK = 0x41;
const int CDVD_MODE2_TRACK = 0x61;
const int CDVD_AUDIO_MASK  = 0x00;
const int CDVD_DATA_MASK   = 0x40;
//	CDROM_DATA_TRACK	0x04	//do not enable this! (from linux kernel)

struct CDVD_TD { uint lsn; ubyte type; }
struct CDVD_TN { ubyte strack, etrack; }

struct CDVD_SubQ {
	ubyte ctrl_mode;
	ubyte trackNum;
	ubyte trackIndex;
	ubyte trackM;
	ubyte trackS;
	ubyte trackF;
	ubyte pad;
	ubyte discM;
	ubyte discS;
	ubyte discF;
}

export extern (Windows) char*  PS2EgetLibName()    { return "CDVDfs Driver"; }
export extern (Windows) uint   PS2EgetLibType()    { return 8; }
export extern (Windows) uint   PS2EgetLibVersion2(uint type) { return 0x050000; }

export extern (Windows) void   CDVDconfigure()     {}
export extern (Windows) void   CDVDabout()         {}
export extern (Windows) int    CDVDtest()          { return 0; }

export extern (Windows) CDVD_TYPE CDVDgetDiskType()   { return CDVD_TYPE.PS2DVD; }
export extern (Windows) CDVD_TRAY CDVDgetTrayStatus() { return CDVD_TRAY.CLOSE; }
export extern (Windows) int    CDVDctrlTrayOpen()  { return 0; }
export extern (Windows) int    CDVDctrlTrayClose() { return 0; }
export extern (Windows) ubyte* CDVDgetBuffer()     { return buffer.ptr; }

char[] isofile = "";
char[] fspath = ".";
ubyte[0x800] buffer; // 1 sector
Stream file;
Iso iso;
Iso[char[]] cvms;
//Stream isoh;

debug = cdvd_log;

export extern (Windows) int CDVDinit() {
	debug (cdvd_log) writefln("CDVDinit()");
	return 0;
}
export extern (Windows) void CDVDshutdown() {
	debug (cdvd_log) writefln("CDVDshutdown()");
}

export extern (Windows) int CDVDopen(char* pTitle) {
	debug (cdvd_log) writefln("CDVDopen('%s')", toString(pTitle));

	try {
		Stream ini = new BufferedFile("cdvdfs.cfg");
		isofile = ini.readLine();
		fspath = ini.readLine();
	} catch {
		writefln("Can't reaad 'cdvdfs.cfg'");
		
		return -1;
	}
	
	writefln("ISO   : %s", isofile);
	writefln("FSPATH: %s", fspath);

	file = new BufferedFile(isofile);
	iso = new Iso(file);
	
	foreach (e; iso.childs) {
		//writefln(e.name);
		if (e.name.length > 4 && e.name[e.name.length - 4.. e.name.length] == ".CVM") {
			//if (!std.file.isfile(fspath ~ "/" ~ e.name)) {
			cvms[e.name] = new Iso(e.open);
			foreach (ee; cvms[e.name]) {
				//writefln("%s/%s", e.name, ee.name);
			}
			//}
		}
	}
	
	//isoh = new MemoryStream();
	//isoh.write(read("iso.license"));
	
	return 0;
}

export extern (Windows) void CDVDclose() {
	if (file) file.close();
	debug (cdvd_log) writefln("CDVDclose()");
}

char[] latest_name = "";
uint latest_offset = 0;
uint latest_start_offset = 0;

export extern (Windows) int CDVDreadTrack(uint lsn, CDVD_MODE mode) {
	//debug (cdvd_log) writefln("CDVDreadTrack(%d, %d)", lsn, mode);
	if (!file) return -1;
	switch (mode) {
		case CDVD_MODE.M_2048:
			ulong offset;
			IsoEntry ie;
			ie = iso.locateFile(lsn, offset);
			//writefln("-");
			
			char[] name = "";
			
			//writefln("-");
			
			if (ie) {
				//writefln("Is file: %s, %s", fspath, ie.name);
				if (std.file.exists(fspath ~ "/" ~ ie.name) && std.file.isfile(fspath ~ "/" ~ ie.name)) {
					//writefln("Is file: %s", fspath ~ "/" ~ ie.name);
				} else {
					if ((ie.name in cvms) !is null) {
						name ~= std.string.format("%s/", ie.name);
						ie = cvms[ie.name].locateFile(lsn - (((cast(IsoEntry)iso[ie.name]).dr.Extent & 0xFFFFFFFF) + 3), offset);
					}
				}
				name ~= ie ? ie.name : "nofile";
			} else {
				name ~= "nofile";
			}
			
			//writefln("-");
			
			char[] rname = fspath ~ "/" ~ name;
			char[] sname = name;

			if ((ie !is null) && std.file.exists(rname) && std.file.isfile(rname)) {
				sname = rname;
				Stream s = new BufferedStream(new File(rname));
				s.position = offset;
				for (int n = 0; n < 0x800; n++) buffer[n] = 0;
				s.read(buffer[0..0x800]);
				s.close();
			} else {
				file.position = lsn * 0x800;
				file.read(buffer[0..0x800]);
			}
			
			bool update = false;
			
			if (latest_name != name) update = true;
			
			if ((latest_name != name) || (lsn != latest_offset + 1)) {
				writefln("          Readed: %d", (latest_offset - latest_start_offset + 1) * 0x800);
				update = true;
			}

			if (update) {
				writefln("::::::: %s (%d)", sname, offset);
				latest_name = name;
				latest_start_offset = lsn;
			}
			
			latest_offset = lsn;
		break;
		default: return -1;
	}
	return 0;
}

export extern (Windows) int CDVDreadSubQ(uint lsn, CDVD_SubQ* subq) {
	debug (cdvd_log) writefln("CDVDreadSubQ(%d, %d)", lsn, subq);
	return -1;
}

export extern (Windows) int CDVDgetTN(CDVD_TN *Buffer) {
	debug (cdvd_log) writefln("CDVDgetTN(%d)", Buffer);
	return -1;
}

export extern (Windows) int CDVDgetTD(ubyte Track, CDVD_TD *Buffer) {
	debug (cdvd_log) writefln("CDVDgetTD(%d, %d)", Track, Buffer);
	return -1;
}

export extern (Windows) int CDVDgetTOC(void* toc) {
	//debug (cdvd_log) writefln("CDVDgetTOC(%d)", toc);
	return -1;
}