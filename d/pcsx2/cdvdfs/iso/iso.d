module iso; // http://www.ecma-international.org/publications/standards/Ecma-119.htm

public import std.stream, std.stdio, std.file, std.intrinsic, std.date;

// Utilities
template TA(T) { u8[] TA(inout T t) { return (cast(u8 *)&t)[0..T.sizeof]; } }
static void Fill(u8[] v, u8 c = 0) { int l = v.length; u8 *ptr = v.ptr; while (l--) *ptr++ = c; }
static void setString(char[] d, char[] s, char padc = ' ') { setString(cast(u8[])d, cast(u8[])s, padc); }
static void setString(u8[] d, char[] s, char padc = ' ') { setString(d, cast(u8[])s, padc); }
static void setString(u8[] d, u8[] s, char padc = '\0') { if (d.length <= s.length) d[0..d.length] = s; else { d[0..s.length] = s; Fill(d[s.length..d.length], cast(u8)padc); } }
static void setStringz(u8[] d, char[] s) { setString(d, s, '\0'); }

abstract class ISO_Sector {
	static const int SECTOR_SIZE = 0x800;
	u32 lba;
	Stream s;
	
	void finalizeSector() {
		if (s.position % 0x800 == 0) return;
		u8[] temp; temp.length = 0x800 - s.position % 0x800;
		s.write(temp); lba = s.position / 0x800;
	}
	
	void writeSector(u8[] data) {
		writefln("[WSECTOR:%3d] %d", lba, data.length);
		if (data.length < 0x800) {
			u8[] temp; temp.length = 0x800 - data.length;
			s.write(data);
			s.write(temp);
		} else {
			s.write(data[0..0x800]);
		}
		lba++;
	}
	
	void writeEmptySector(int n = 1) { u8[0x800] temp; while (n--) writeSector(temp); }
	void writeSectors(u8[] data) { for (int n = 0; n < data.length; n += 0x800) writeSector(data[n..n + 0x800]); }
	
	static u32 getSectors(ulong size) {
		return (size / 0x800) + (size % 0x800 != 0);
	}	
}

// Types
// Signed
alias byte  s8;
alias short s16;
alias int   s32;
alias long  s64;
// Unsigned
alias ubyte  u8;
alias ushort u16;
alias uint   u32;
alias ulong  u64;
// Both Byte Order Types
align(1) struct u16b { u16 l, b; void opAssign(u16 v) { l = v; b = bswap(v) >> 16; } }
align(1) struct u32b { u32 l, b; void opAssign(u32 v) { l = v; b = bswap(v); } }

class ISO : ISO_Sector {
	// Information
	char[] SystemId            = "SYSTEM_ID";
	char[] VolumeId            = "VOLUME_ID";
	char[] VolumeSetId         = "VOLUME_SET_ID";
	char[] PublisherId         = "PUBLISHER_ID";
	char[] PreparerId          = "PREPARER_ID";
	char[] ApplicationId       = "APPLICATION_ID";
	char[] CopyrightFileId     = "COPYRIGHT_FILE_ID";
	char[] AbstractFileId      = "ABSTRACT_FILE_ID";
	char[] BibliographicFileId = "BIBLIOGRAPHIC_FILE_ID";
	d_time CreationDate;
	d_time ModificationDate;
	d_time ExpirationDate;
	d_time EffectiveDate;
	
	u8[0x8000] systemArea;
	PrimaryVolumeDescriptor pvd;
	u16 fileCount = 0; // Max 64K of files
	
	// 8.4.26 Volume Creation Date and Time (BP 814 to 830)
	align (1) struct Date {
		union {
			struct {
				char year[4]    = "0000";
				char month[2]   = "00";
				char day[2]     = "00";
				char hour[2]    = "00";
				char minute[2]  = "00";
				char second[2]  = "00";
				char hsecond[2] = "00";
				u8   offset     = 0;
			}
			u8 v[17];
		}
	}
	
	// 9.1 Format of a Directory Record
	align (1) struct DirectoryRecord {
		align(1) struct Date {
			union {
				struct { u8 year, month, day, hour, minute, second, offset; }
				u8[7] v;
			}
			
			void opAssign(d_time t) {
				std.date.Date date;
				date.parse(std.date.toUTCString(t));
				year   = date.year - 1900;
				month  = date.month;
				day    = date.day;
				hour   = date.hour;
				minute = date.minute;
				second = date.second;
				offset = 0;				
			}
		}
	
		u8   Length;
		u8   ExtAttrLength;
		u32b Extent;
		u32b Size;
		Date date; // 9.1.5 Recording Date and Time (BP 19 to 25)
		u8   Flags;
		u8   FileUnitSize;
		u8   Interleave;
		u16b VolumeSequenceNumber;
		u8   NameLength;
	}
	
	// 8 Volume Descriptors
	align (1) struct VolumeDescriptor {
		enum Type : u8 {
			BootRecord                    = 0x00, // 8.2 Boot Record
			VolumePartitionSetTerminator  = 0xFF, // 8.3 Volume Descriptor Set Terminator
			PrimaryVolumeDescriptor       = 0x01, // 8.4 Primary Volume Descriptor
			SupplementaryVolumeDescriptor = 0x02, // 8.5 Supplementary Volume Descriptor
			VolumePartitionDescriptor     = 0x03, // 8.6 Volume Partition Descriptor
		}
		
		Type type;
		u8   id[5];
		u8   ver;
		u8   data[2041];
	}
	
	// 8.4 Primary Volume Descriptor
	align (1) struct PrimaryVolumeDescriptor {
		VolumeDescriptor.Type type;
		u8 id[5];
		u8 ver;
		
		u8   _1;
		u8   SystemId[0x20];
		u8   VolumeId[0x20];
		u64  _2;
		u32b VolumeSpaceSize;
		u64  _3[4];
		u32   VolumeSetSize;
		u32  VolumeSequenceNumber;
		u16b  LogicalBlockSize;
		u32b PathTableSize;
		u32  TypeLPathTable;
		u32  OptType1PathTable;
		u32  TypeMPathTable;
		u32  OptTypeMPathTable;
		
		DirectoryRecord dr;
		
		u8   _4;
		u8   VolumeSetId[0x80];
		u8   PublisherId[0x80];
		u8   PreparerId[0x80];
		u8   ApplicationId[0x80];
		u8   CopyrightFileId[37];
		u8   AbstractFileId[37];
		u8   BibliographicFileId[37];
		
		Date CreationDate;
		Date ModificationDate;
		Date ExpirationDate;
		Date EffectiveDate;
		u8   FileStructureVersion;
		u8   _5;
		u8   ApplicationData[0x200];
		u8   _6[653];
	}
	
	// 8.5 Supplementary Volume Descriptor
	// -
	
	// 8.6 Volume Partition Descriptor
	// -
	
	static assert (Date.sizeof == 17, "Invalid Date Size");
	static assert (DirectoryRecord.Date.sizeof == 7, "Invalid DirectoryRecord.Date Size");
	static assert (DirectoryRecord.sizeof == 33, "Invalid DirectoryRecord Size");
	static assert (VolumeDescriptor.sizeof == 0x800, "Invalid VolumeDescriptor Size");
	static assert (PrimaryVolumeDescriptor.sizeof == VolumeDescriptor.sizeof, "Invalid PrimaryVolumeDescriptor Size");	
	
	VolumeDescriptor* VD(void *v) { return cast(VolumeDescriptor*)v; }
	void setVolumeDescriptor(VolumeDescriptor *vd, VolumeDescriptor.Type type) {
		vd.type = type; setStringz(vd.id, "CD001"); vd.ver = 0x01;
	}
	
	void writePrimaryVolumeDescriptor() {
		setString(pvd.SystemId, SystemId);
		setString(pvd.VolumeId, VolumeId);
		setString(pvd.VolumeSetId, VolumeSetId);
		setString(pvd.PublisherId, PublisherId);
		setString(pvd.PreparerId, PreparerId);
		setString(pvd.ApplicationId, ApplicationId);
		setString(pvd.CopyrightFileId, CopyrightFileId);
		setString(pvd.AbstractFileId, AbstractFileId);
		setString(pvd.BibliographicFileId, BibliographicFileId);
		
		pvd.LogicalBlockSize = 0x800;
		
		setVolumeDescriptor(VD(&pvd), VolumeDescriptor.Type.PrimaryVolumeDescriptor);

		writeSector(TA(pvd));
	}
	
	void writeVolumePartitionSetTerminator() {
		VolumeDescriptor vd;
		setVolumeDescriptor(VD(&vd), VolumeDescriptor.Type.VolumePartitionSetTerminator);
		writeSector(TA(vd));
	}

	void writeHeader() {
		writeSectors(systemArea);
		writePrimaryVolumeDescriptor();
		writeVolumePartitionSetTerminator();
	}
	
	void finish() {
		writefln("Finish, sectors size: %d", getSectors(s.size));
		writefln("File count: %d", fileCount);

		pvd.VolumeSpaceSize = getSectors(s.size);
		pvd.PathTableSize = fileCount;
		s.position = 0x800 * 0x10;
		writeSector(TA(pvd));
		//(cast(EntryDR)root).updateDr();
	}
	
	Stream drPut(DirectoryRecord dr, char[] name) {
		dr.Length = dr.sizeof + name.length;
		dr.NameLength = name.length;	
		if ((0x800 - s.position % 0x800) < dr.Length) finalizeSector();
		Stream rs = new SliceStream(s, s.position, s.position + dr.sizeof);
		writefln("SliceStream(%d:%d)", s.position, dr.sizeof);
		s.write(TA(dr));
		s.writeString(name);
		return rs;
	}
}