module isofs;

private import std.file, std.string, std.stdio, std.path, std.regexp, std.stream, std.intrinsic;

template TA(T) { ubyte[] TA(inout T t) { return (cast(ubyte *)&t)[0..T.sizeof]; } }

abstract class ContainerEntry {
	ContainerEntry parent;
	ContainerEntry[] childs;
	char[] name;
	Stream open () { throw(new Exception("'open' Not implemented")); }
	void close() { throw(new Exception("'close' Not implemented")); }

	char[] type() {
		return "";
	}

	void print() {
		writefln("%s('%s')", this, name);
	}

	void saveto(Stream s) {
		Stream cs = this.open();
		s.copyFrom(cs);
		s.flush();
		//this.close();
	}

	ubyte[] read() {
		ubyte[] ret;
		MemoryStream s = new MemoryStream();
		saveto(s);
		ret.length = s.data.length;
		ret[0..ret.length] = s.data[0..ret.length];
		delete s;
		return ret;
	}

	public void saveto(char[] s) {
		File f = new File(s, FileMode.OutNew);
		saveto(f);
		f.close();
	}

	void list(char[] base = "") {
		print();
		foreach (child; childs) {
			if (!child.name) continue;
			writefln("'%s%s'", base, child.name);
			if (child.childs.length) child.list(format("%s/", child.name));
		}
	}

	void add(ContainerEntry ce) {
		childs ~= ce;
		ce.parent = this;
	}

	ContainerEntry opIndex(char[] name) {
		if (std.string.find(name, '/') != -1) throw(new Exception("Only root files implemented"));
		foreach (child; childs) {
			if (std.string.icmp(child.name, name) == 0) return cast(ContainerEntry)child;
		}
		throw(new Exception(format("File '%s' doesn't exists", name)));
	}

    int opApply(int delegate(inout ContainerEntry) dg) {
    	int result = 0;

		for (int n = 0; n < childs.length; n++) {
			result = dg(childs[n]);
			if (result) break;
		}

		return result;
    }

	// Reemplazamos un stream
	ulong replace(Stream from, bool limited = true) {
		//writefln("ContainerEntry.replace(%08X);", cast(uint)cast(uint *)this);
		Stream op = this.open();
		//writefln("%d", op.writeable);
		ulong start = op.position;
		
		op.copyFrom(from);
		
		return op.position - start;
	}
	
	ulong replaceAt(Stream from, int skip = 0) {
		//writefln("ContainerEntry.replace(%08X);", cast(uint)cast(uint *)this);
		Stream op = this.open();
		//writefln("%d", op.writeable);
		ulong start = op.position;
		op.position = start + skip;
		op.copyFrom(from);
		return op.position - start;
	}

	// Reemplazamos por un fichero
	void replace(char[] from, bool limited = true) {
		File f = new File(from, FileMode.In);
		replace(f, limited);
		f.close();
	}
	
	// Reemplazamos por un fichero
	void replaceAt(char[] from, int skip = 0) {
		File f = new File(from, FileMode.In);
		replaceAt(f, skip);
		f.close();
	}	

	bool isFile() {
		return false;
	}
}

abstract class ContainerEntryWithStream : ContainerEntry {
	Stream stream;

	Stream rs;

	void setData(void[] data) {
		setStream(new MemoryStream(cast(ubyte[])data));
	}

	void setStream(Stream s) {
		//close();
		rs = s;
		s.position = 0;
	}

	Stream open() {
		if (rs) return rs;

		//writefln("ContainerEntry.open(%08X);", cast(uint)cast(uint *)this);
		if (stream && stream.isOpen) {
			//writefln("opened");
			stream.position = 0;
			return stream;
		}
		//writefln("realopen");
		return stream = realopen();
	}

	void close() {
		//writefln("ContainerEntry.close(%08X);", cast(uint)cast(uint *)this);
		if (stream && stream.isOpen) {
			//writefln("closd");
			stream.close();
		}
	}

	protected Stream realopen(bool limited = true) {
		throw(new Exception("realopen: Not Implemented (" ~ this.toString ~ ")"));
	}
}


align(1) struct IsoDate {
	ubyte info[17]; // 8.4.26.1
}

static ulong s733(uint v) {
	return cast(ulong)v | ((cast(ulong)bswap(v)) << 32);
}

align(1) struct IsoDirectoryRecord {
	ubyte   Length;
    ubyte   ExtAttrLength;
	ulong   Extent;
	ulong   Size;
	ubyte   Date[7];
	ubyte   Flags;
	ubyte   FileUnitSize;
	ubyte   Interleave;
	uint    VolumeSequenceNumber;
	ubyte   NameLength;
	//ubyte   _Unused;
	//char    Name[0x100];
}

struct IsoVolumeDescriptor {
	ubyte Type;
	char Id[5];
	ubyte Version;
	ubyte Data[2041];
};


// 0x800 bytes (1 sector)
align(1) struct IsoPrimaryDescriptor {
	ubyte Type;
	char  Id[5];
	ubyte Version;
	ubyte _Unused1;
	char  SystemId[0x20];
	char  VolumeId[0x20];
	ulong _Unused2;
	ulong VolumeSpaceSize;
	ulong _Unused3[4];
	uint  VolumeSetSize;
	uint  VolumeSequenceNumber;
	uint  LogicalBlockSize;
	ulong PathTableSize;
	uint  Type1PathTable;
	uint  OptType1PathTable;
	uint  TypeMPathTable;
	uint  OptTypeMPathTable;
	IsoDirectoryRecord RootDirectoryRecord;
	ubyte _Unused3b;
	char  VolumeSetId[128];
	char  PublisherId[128];
	char  PreparerId[128];
	char  ApplicationId[128];
	char  CopyrightFileId[37];
	char  AbstractFileId[37];
	char  BibliographicFileId[37];
	IsoDate CreationDate;
	IsoDate ModificationDate;
	IsoDate ExpirationDate;
	IsoDate EffectiveDate;
	ubyte FileStructureVersion;
	ubyte _Unused4;
	ubyte ApplicationData[512];
	ubyte _Unused5[653];
};

void Dump(IsoDirectoryRecord idr) {
	writefln("IsoDirectoryRecord {");
	writefln("  Length:               %02X", idr.Length);
	writefln("  ExtAttrLength:        %02X", idr.ExtAttrLength);
	writefln("  Extent:               %08X", idr.Extent & 0xFFFFFFFF);
	writefln("  Size:                 %08X", idr.Size & 0xFFFFFFFF);
	writefln("  Date:                 [...]");
	writefln("  Flags:                %02X", idr.Flags);
	writefln("  FileUnitSize:         %02X", idr.FileUnitSize);
	writefln("  Interleave:           %02X", idr.Interleave);
	writefln("  VolumeSequenceNumber: %08X", idr.VolumeSequenceNumber);
	writefln("  NameLength:           %08X", idr.NameLength);
	writefln("}");
	writefln();
}

void Dump(IsoPrimaryDescriptor ipd) {
	writefln("IsoPrimaryDescriptor {");
	writefln("  Type:                 %02X",   ipd.Type);
	writefln("  ID:                   '%s'",   ipd.Id);
	writefln("  Version:              %02X",   ipd.Version);
	writefln("  SystemId:             '%s'",   ipd.SystemId);
	writefln("  VolumeId:             '%s'",   ipd.VolumeId);
	writefln("  VolumeSpaceSize:      %016X",  ipd.VolumeSpaceSize);
	writefln("  VolumeSetSize:        %08X",   ipd.VolumeSetSize);
	writefln("  VolumeSequenceNumber: %08X",   ipd.VolumeSequenceNumber);
	writefln("  LogicalBlockSize:     %08X",   ipd.LogicalBlockSize);
	writefln("  PathTableSize:        %016X",  ipd.PathTableSize);
	writefln("  Type1PathTable:       %08X",   ipd.Type1PathTable);
	writefln("  OptType1PathTable:    %08X",   ipd.OptType1PathTable);
	writefln("  TypeMPathTable:       %08X",   ipd.TypeMPathTable);
	writefln("  OptTypeMPathTable:    %08X",   ipd.OptTypeMPathTable);
	writefln("  RootDirectoryRecord:  [...]");
	Dump(ipd.RootDirectoryRecord);
	writefln("  VolumeSetId:          '%s'",   ipd.VolumeSetId);
	writefln("  PublisherId:          '%s'",   ipd.PublisherId);
	writefln("  PreparerId:           '%s'",   ipd.PreparerId);
	writefln("  ApplicationId:        '%s'",   ipd.ApplicationId);
	writefln("  CopyrightFileId:      '%s'",   ipd.CopyrightFileId);
	writefln("  AbstractFileId:       '%s'",   ipd.AbstractFileId);
	writefln("  BibliographicFileId:  '%s'",   ipd.BibliographicFileId);
	writefln("  CreationDate:         [...]");
	writefln("  ModificationDate:     [...]");
	writefln("  ExpirationDate:       [...]");
	writefln("  EffectiveDate:        [...]");
	writefln("  FileStructureVersion: %02X",   ipd.FileStructureVersion);
	writefln("}");
	writefln();
}

class IsoEntry : ContainerEntryWithStream {
	Stream drstream;
	IsoDirectoryRecord dr;
	Iso iso;
	uint udf_extent;
	
	char[] fullname;

	override void print() {
		writefln(this.toString);
		Dump(dr);
	}

	// Escribimos el DirectoryRecord
	void writedr() {
		drstream.position = 0;
		drstream.write(TA(dr));
		
		// Actualizamos tambien el udf
		if (udf_extent) {
			//writefln("UDF: %08X", udf_extent);
			Stream udfs = new SliceStream(iso.stream, 0x800 * udf_extent, 0x800 * (udf_extent + 1));
			udfs.position = 0x38;
			udfs.write(cast(uint)(dr.Size & 0xFFFFFFFF));
			udfs.position = 0x134;
			//writefln("%08X", dr.Size & 0xFFFFFFFF);
			udfs.write(cast(uint)(dr.Size & 0xFFFFFFFF));
			udfs.write(cast(uint)((dr.Extent & 0xFFFFFFFF) - 262));
			//writefln("patching udf");
		}
	}

	// Cantidad de sectores necesarios para almacenar
	uint Sectors() {
		return iso.sectors(dr.Size);
	}

	override ulong replace(Stream from, bool limited = true) {
		Stream op = iso.openDirectoryRecord(dr, limited);
		ulong start = op.position;
		op.copyFrom(from);
		ulong length = op.position - start;
		op.close();
		dr.Size = s733(length);
		writedr();
		return length;
	}

	override ulong replaceAt(Stream from, int skip = 0) {
		Stream op = iso.openDirectoryRecord(dr, false);
		ulong start = op.position;
		op.position = start + skip;
		op.copyFrom(from);
		ulong length = op.position - start;
		op.close();
		dr.Size = s733(length);
		writedr();
		return length;
	}

	void swap(IsoEntry ie) {
		if (ie.iso != this.iso) throw(new Exception("Only can swap entries in same iso file"));

		int TempExtent, TempSize;

		TempExtent = ie.dr.Extent;
		TempSize   = ie.dr.Size;

		ie.dr.Extent = this.dr.Extent;
		ie.dr.Size   = this.dr.Size;

		this.dr.Extent = TempExtent;
		this.dr.Size   = TempSize;

		this.writedr();
		ie.writedr();
	}

	void use(IsoEntry ie) {
		if (ie.iso != this.iso) throw(new Exception("Only can swap entries in same iso file"));

		this.dr.Extent = ie.dr.Extent;
		this.dr.Size   = ie.dr.Size;

		this.writedr();
	}

	/*override protected Stream realopen(bool limited = true) {
		throw(new Exception(""));
	}*/
}

class IsoDirectory : IsoEntry {
	Stream open() {
		throw(new Exception(""));
	}
	
	void clearFiles() {
		foreach (ce; this) {
			IsoEntry ie = cast(IsoEntry)ce;
			if (ie.classinfo.name == IsoFile.classinfo.name) {
				ie.dr.Extent = s733(0);
				ie.dr.Size   = s733(0);
				ie.writedr();
			} else if (ie.classinfo.name == IsoDirectory.classinfo.name) {
				if (ie != this) (cast(IsoDirectory)ie).clearFiles();
			}
		}
	}
}

class IsoFile : IsoEntry {
	uint size;
	
	override bool isFile() {
		return true;
	}

	//override protected Stream realopen(bool limited = true) {
	override Stream realopen(bool limited = true) {		
		//writefln("%s", name);
		//writefln("%08X", (dr.Size >> 32) & 0x_FFFFFFFF);
		return iso.openDirectoryRecord(dr);
	}
}

class SliceStreamNoClose : SliceStream {
	this(Stream s, ulong pos, ulong len) { super(s, pos, len); }
	this(Stream s, ulong pos) { super(s, pos); }

	override void close() { Stream.close(); }
}

class Iso : IsoDirectory {
	IsoPrimaryDescriptor ipd;
	Stream stream;
	uint position = 0;
	uint datastart = 0xFFFFFFFF;
	uint firstDatasector = 0xFFFFFFFF;
	uint lastDatasector = 0x00000000;
	uint writeDatasector = 0x00000000;
		
	Iso copyIsoStructure(Stream s) {
		Iso iso;
		//writefln(firstDatasector);
		
		if (firstDatasector > 3000) throw(new Exception("ERROR!"));
		
		//s.copyFrom(new SliceStream(stream, 0, (cast(ulong)firstDatasector) * 0x800));
		//writefln(firstDatasector);
		s.copyFrom(new SliceStream(stream, 0, (cast(ulong)firstDatasector) * 0x800));
		s.position = 0;
		
		iso = new Iso(s);
		iso.writeDatasector = iso.firstDatasector;
		
		iso.clearFiles();
		
		return iso;
	}
	
	void copyUnrecreatedFiles(Iso iso, bool show = true) {
		//writefln("copyUnrecreatedFiles()");
		foreach (ce; this) {			
			IsoEntry ie = cast(IsoEntry)ce;			
			if (ie.dr.Extent) continue;
				
			if (show) printf("%s...", toStringz(ce.name));
				
			recreateFile(ie, iso[ie.name].open, 5);	iso[ie.name].close();
			
			if (show) printf("Ok\n");
		}
		stream.flush();
	}
	
	void recreateFile(ContainerEntry ce) {
		IsoEntry e  = cast(IsoEntry)ce;
		e.dr.Extent = s733(1);
		e.dr.Size   = s733(0);
		e.writedr();
	}
	
	void recreateFile(ContainerEntry ce, char[] n, int addVoidSectors = 0) {
		Stream s = new File(n, FileMode.In);
		recreateFile(ce, s, addVoidSectors);
		s.close();
	}
	
	void recreateFile(ContainerEntry ce, Stream s, int addVoidSectors = 0) {
		s.position = 0;		
		//printf("Available: %d\n", cast(int)(s.available & 0xFFFFFFFF));
		Stream w = startFileCreate(ce);
		uint pos = w.position;		

		uint available = s.available;
		
		w.copyFrom(s);
		w.position = pos + available;
		
		//printf("Z: %d | (%d)\n", cast(int)(w.position - pos), s.available);
		endFileCreate(addVoidSectors);
	}
	
	ContainerEntry oce; // OpenedContainerEntry
	Stream writing;
	Stream startFileCreate(ContainerEntry ce) {
		oce = ce;
		if ((cast(IsoEntry)ce).iso != this) throw(new Exception("Only can update entries in same iso file"));
		//printf("{START: %08X}\n", writeDatasector);
		uint spos = (cast(ulong)writeDatasector) * 0x800;
		{
			stream.seek(0, SeekPos.End);
			ubyte[] temp; temp.length = 0x800 * 0x100;
			while (stream.position < spos) {
				if (spos - stream.position > temp.length) {
					stream.write(temp);
				} else {
					stream.write(temp[0..spos - stream.position]);
					//stream.position - spos
				}
			}
		}
		writing = new SliceStream(stream, spos);
		return writing;
	}
	
	void endFileCreate(int addVoidSectors = 0) {
		writing.position = 0; uint length = writing.available;
		
		IsoEntry e = cast(IsoEntry)oce;
		e.dr.Extent = s733(writeDatasector);
		e.dr.Size = s733(length);
		e.writedr();
		writeDatasector += sectors(length) + addVoidSectors;
		
		//printf("| {END: %08X}\n", writeDatasector);
		
		if (length % 0x800) {
			stream.position = (cast(ulong)writeDatasector) * 0x800 - 1;
			stream.write(cast(ubyte)0);
		}
	}	

	override void print() {
		Dump(ipd);
	}
	
	static uint sectors(ulong size) {
		uint sect = (size / 0x800);
		if ((size % 0x800) != 0) sect++;
		return sect;
	}
	
	void processFileDR(IsoDirectoryRecord dr) {
		uint ssect = (dr.Extent & 0xFFFFFFFF);
		uint size  = (dr.Size   & 0xFFFFFFFF);
		uint sectl = sectors(size);
		uint esect = ssect + sectl;
		
		//writefln("%08X", ssect);
		
		if (ssect < firstDatasector) firstDatasector = ssect;
		if (esect > lastDatasector ) lastDatasector  = esect;
	}
	
	Stream openDirectoryRecord(IsoDirectoryRecord dr, bool limited = true) {
		ulong from = getSectorPos(dr.Extent & 0x_FFFF_FFFF);
		uint size  = (dr.Size & 0x_FFFF_FFFF);
		return limited ? (new SliceStreamNoClose(stream, from, from + size)) : (new SliceStreamNoClose(stream, from));
	}

	ubyte[] readSector(uint sector) {
		ubyte[] ret; ret.length = 0x800;
		stream.position = getSectorPos(sector);
		stream.read(ret);
		return ret;
	}

	private ulong getSectorPos(uint sector) {
		return (cast(ulong)sector) * 0x800;
	}

	private void processDirectory(IsoDirectory id) {
		IsoDirectoryRecord dr;
		IsoDirectoryRecord bdr = id.dr;
		int cp;
		
		stream.position = getSectorPos(bdr.Extent & 0x_FFFF_FFFF);
		uint maxPos = stream.position + (bdr.Size & 0x_FFFF_FFFF);
		
		//Dump(bdr);
		
		while (true) {
			char[] name;
			Stream drstream;

			uint bposition = stream.position;

			drstream = new SliceStream(stream, stream.position, stream.position + dr.sizeof);
			stream.read(TA(dr));

			//writefln("%08X", bposition);
			//Dump(dr);
			//writefln("%08X", dr.Length);
			
			if (!dr.Length) {
				stream.position = getSectorPos(bposition / 0x800 + 1);
				
				drstream = new SliceStream(stream, stream.position, stream.position + dr.sizeof);
				stream.read(TA(dr));
			}
			
			if (stream.position >= maxPos) break;

			name.length = dr.Length - dr.sizeof;
			stream.read(cast(ubyte[])name);
			name.length = dr.NameLength;

			//writefln(":'%s'", name); Dump(dr);
			
			//processDR(dr);

			if (dr.NameLength && name[0] != 0 && name[0] != 1) {
				//writefln("DIRECTORY: '%s'", name);
				// Directorio
				if (dr.Flags & 2) {
					IsoDirectory cid = new IsoDirectory();
					cid.drstream = drstream;
					cid.iso = this;
					cid.dr = dr;
					id.add(cid);
					cid.name = name[0..name.length - 2];

					uint bp = stream.position;
					{
						processDirectory(cid);
					}
					stream.position = bp;
				}
				// Fichero
				else {
					processFileDR(dr);
					if (cast(uint)dr.Extent < datastart) datastart = dr.Extent;
					IsoFile cif = new IsoFile();
					cif.drstream = drstream;
					cif.iso = this;
					cif.dr = dr;
					cif.size = dr.Size;
					cif.name = name[0..name.length - 2];
					id.add(cif);
					//writefln("%08X - %s", cast(uint)dr.Size, cif.name);
				}
			} else {
				IsoEntry ie = new IsoEntry();
				ie.iso = this;
				ie.dr = dr;
				id.add(ie);
				//Dump(dr);
			}
		}
	}

	this(Stream s) {
		ubyte magic[4];
		//stream = new PatchedStream(s);
		stream = s;

		stream.position = 0;

		stream.read(magic);

		if (cast(char[])magic == "CVMH") {
			stream.position = 0;
			stream = new SliceStream(stream, 0x1800);
		}

		stream.position = getSectorPos(0x10);
		stream.read(TA(ipd));

		this.dr = ipd.RootDirectoryRecord;
		this.name = "/";

		processDirectory(this);
		
		writeDatasector = lastDatasector;
		
		//try { _udf_check(); } catch (Exception e) { }
	}

	this(char[] s, bool readonly = false) {
		Stream f;
		
		try {
			f = new File(s, readonly ? FileMode.In : (FileMode.In | FileMode.Out));
		} catch (Exception e) {
			f = new BufferedFile(s, FileMode.In);
		}
		
		this(f);
	}

	private this() { }

	void copyIsoInfo(Iso from) {
		ubyte[0x800 * 0x10] data;
		int fromposition = from.stream.position; scope(exit) { from.stream.position = fromposition; }
		from.stream.position = 0;
		from.stream.read(data);
		this.stream.write(data);
		this.ipd = from.ipd;
		this.position = 0x800 * 0x11;
		this.datastart = from.datastart;
	}

	static Iso create(Stream s) {
		Iso iso = new Iso;
		iso.stream = s;
		return iso;
	}

	void swap(char[] a, char[] b) {
		(cast(IsoEntry)this[a]).swap(cast(IsoEntry)this[b]);
	}

	void use(char[] a, char[] b) {
		(cast(IsoEntry)this[a]).use(cast(IsoEntry)this[b]);
	}
	
	//void _udf_test() {
	void _udf_check() {
		char[] decodeDstringUDF(ubyte[] s) {
			char[] r;
			if (s.length) {
				ubyte bits = s[0];
				switch (bits) {
					case 8:
						for (int n = 1; n < s.length; n++) r ~= s[n];
					break;
					case 16:
						for (int n = 2; n < s.length; n += 2) r ~= s[n];
					break;
				}
			}
			return r;
		}
		
		stream.position = 0x800 * 264;
				
		int count = 0;
		
		while (true) {
			uint ICB_length, ICB_extent;
			ubyte FileCharacteristics, LengthofFileIdentifier;
			ushort FileVersionNumber, LengthofImplementationUse;

			// Padding			
			while (stream.position % 4) stream.position = stream.position + 1;

			// Escapamos el tag
			stream.seek(0x10, SeekPos.Current);
			
			stream.read(FileVersionNumber);			
			if (FileVersionNumber != 0x01) {
				//writefln("%08X : %04X", stream.position - 2, FileVersionNumber);
				break;
			}
			
			//writefln("%08X", stream.position - 2);
			
			stream.read(FileCharacteristics);
			stream.read(LengthofFileIdentifier);			
			stream.read(ICB_length);
			stream.read(ICB_extent);
			stream.seek(8, SeekPos.Current);
			
			// Escapamos la implementacion
			stream.read(LengthofImplementationUse);
			stream.seek(LengthofImplementationUse, SeekPos.Current);
			
			ubyte[] name; name.length = LengthofFileIdentifier;
			stream.read(name);			
			
			if (name.length) {
				//writefln("%s : %d", decodeDstringUDF(name), ICB_length);
				(cast(IsoEntry)this[decodeDstringUDF(name)]).udf_extent = ICB_extent + 262;
				//writefln("%s", decodeDstringUDF(name));
				//writefln(this[decodeDstringUDF(name)]);
			}
		}
	}
	
	IsoEntry locateFile(ulong sector, inout ulong offset) {
		foreach (e; childs) { IsoEntry ie = cast(IsoEntry)e;
			uint off = (ie.dr.Extent & 0xFFFFFFFF);
			uint len = sectors(ie.dr.Size & 0xFFFFFFFF);
			if (sector >= off && sector < off + len) {
				offset = (sector - off) * 0x800;
				return ie;
			}
		}
		offset = 0;
		return null;
	}
	
	IsoEntry locateFile(ulong sector) { ulong offset; return locateFile(sector, offset); }
}

class StreamConvertTo2048 : FilterStream {
	int mode;
	int sector_length = 2048, sector_pre = 0;
	long zoffset = 0;
	long sector_cached = -1;
	ubyte[0x800] sector_data;
	
	long sector() { return zoffset / 0x800; }
	
	this(Stream parent, int mode = 0) {
		this.mode = mode;
		switch (mode) {
			case 0: // M_2352 = 0, // full 2352 bytes
				sector_length = 2352;
				sector_pre = 16;
			break;
			case 1: // M_2340 = 1, // skip sync (12) bytes
			case 2: // M_2328 = 2, // skip sync+head+sub (24) bytes
			case 4: // M_2368 = 4, // full 2352 bytes + 16 subq
			default:
				assert(0 == 1, "Only mode 0 and 3 supported.");
			break;
			case 3: // M_2048 = 3, // skip sync+head+sub (24) bytes
				sector_length = 2048;
				sector_pre = 0;
			break;
		}
		super(parent);
	}
	
	uint readBlock(void* _buffer, uint size) { ubyte* buffer = cast(ubyte *)_buffer; int left = size;
		while (left > 0) {
			prepareSector();
			
			int pos = zoffset % 0x800;
			int maxreadlen = 0x800 - pos;
			int readlen = left < maxreadlen ? left : maxreadlen;
			
			buffer[0..readlen] = sector_data[pos..pos + readlen];
			buffer += readlen;
			left -= readlen;
			zoffset += readlen;
		}
		return size;
	}
	
	ulong seek(long offset, SeekPos whence) {
		switch (whence) {
			case SeekPos.Current: zoffset += offset; break;
			case SeekPos.Set: zoffset  = offset; break;
			case SeekPos.End: zoffset  = (source.size * sector_length) / 0x800 - zoffset; break;
		}
		return zoffset;
	}
	
	void prepareSector() { return prepareSector(sector); }
	
	void prepareSector(long sector) {
		if (sector_cached == sector) return; else sector_cached = sector;
		source.position = sector * sector_length + sector_pre;
		source.read(sector_data);
	}
}
