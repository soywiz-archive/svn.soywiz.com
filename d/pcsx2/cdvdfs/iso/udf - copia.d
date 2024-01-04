module udf;

public import iso;

class UDF {
	ulong lba_last_file_entry;
	ulong lba_end_anchor_vol_desc;
	ulong lba_udf_partition_start;
	
	ulong udf_file_entry_sector;
	ulong main_volume_desc_seq_extent;
	ulong reserve_volume_desc_seq_extent;

	/////////////////////////////
	ISO iso;
	ulong StartedDateAndTime;
	uint lba_main_seq, lba_main_seq_copy, lba_integ_seq; // Locations
	uint num_udf_files, num_udf_directories; // File count
	/////////////////////////////

	align(1) struct Tag { // 2.2.1 Descriptor Tag
		enum ID : u16 {
			PrimaryVolumeDescriptor            = 1,   // 2.2.2 Primary Volume Descriptor
			AnchorVolumeDescriptorPointer      = 2,   // 2.2.3 Anchor Volume Descriptor Pointer
			LogicalVolumeDescriptor            = 6,   // 2.2.4 Logical Volume Descriptor
			UnallocatedSpaceDesc               = 7,   // 2.2.5 Unallocated Space Descriptor
			TerminatingDescriptor              = 8,   // ?.?.? ?
			LogicalVolumeIntegrityDesc         = 9,   // 2.2.6 Logical Volume Integrity Descriptor
			ImpUseVolumeDescriptor             = 4,   // 2.2.7 Implementation Use Volume Descriptor
			PartitionDescriptor                = 5,   // 2.2.14 Partition Descriptors
			FileSetDescriptor                  = 256, // 2.3.2 File Set Descriptor
			FileIdentifierDescriptor           = 257, // 2.3.4 File Identifier Descriptor
			FileEntry                          = 261, // 2.3.6 File Entry
			
			EXT_ATTRIBUTE_HEADER_DESC = 262,
			EXT_FILE_ENTRY = 266,
		}	
	
		ID  TagIdentifier;
		u16 DescriptorVersion;
		u8  TagChecksum;
		u8  Reserved;
		u16 TagSerialNumber;
		u16 DescriptorCRC;
		u16 DescriptorCRCLength;
		u32 TagLocation;
	}
	
	void TAG(void *ptr) { return cast(Tag*)ptr; }

	align(1) struct ExtendedAttributeHeaderDescriptor { // 3.3.4.1 Extended Attribute Header Descriptor
		Tag DescriptorTag;
		u32 ImplementationAttributesLocation;
		u32 ApplicationAttributesLocation;
	}
	
	align(1) struct icbtag { // 3.3.2 ICB Tag
		align(1) enum file_type : ubyte {
			Directory = 4,
			ByteSeq   = 5,
			EA        = 8,
			SymLink   = 12,
			StreamDir = 13,
		}

		u32     PriorRecordedNumberofDirectEntries;
		u16     StrategyType;
		u8      StrategyParameter[2];
		u16     MaximumNumberofEntries;
		u8      Reserved;
		file_type FileType;
		lb_addr ParentICBLocation;
		u16     Flags;
	}
	
	alias u32      udf_Uint32;
	alias u16      udf_Uint16;
	alias u8       udf_Uint8;
	alias u8       udf_byte;
	alias u8       udf_zerobyte;
	alias EntityID udf_EntityID;
	
	align(1) struct udf_ext_attribute_free_ea_space {	/* TR/71 3.6.{2,3} */
		udf_Uint32	attribute_type;		/* = 2048 */
		udf_Uint8	attribute_subtype;	/* = 1 */
		udf_zerobyte	reserved[3];
		udf_Uint32	attribute_length;	/* = 52 */
		udf_Uint32	impl_use_length;	/* = 4 */
		udf_EntityID	impl_ident;		/* "*UDF FreeEASpace" */
		udf_Uint16	header_checksum;
		udf_Uint16	free_ea_space;		/* = 0 */
	}
	
	align(1) struct udf_ext_attribute_dvd_cgms_info {
	/* 0*/	udf_Uint32	attribute_type;		/* = 2048 */
	/* 4*/	udf_Uint8	attribute_subtype;	/* = 1 */
	/* 5*/	udf_zerobyte	reserved[3];
	/* 8*/	udf_Uint32	attribute_length;	/* = 56 */
	/*12*/	udf_Uint32	impl_use_length;	/* = 8 */
	/*16*/	udf_EntityID	impl_ident;		/* "*UDF DVD CGMS Info" */
	/*48*/	udf_Uint16	header_checksum;
	/*50*/	udf_byte	cgms_info;
	/*51*/	udf_Uint8	data_structure_type;
	/*52*/	udf_byte	protection_system_info[4];
	/*56*/
	}
	
	align(1) struct udf_fxinfo {
		udf_Uint16	fdiconid;
		udf_Uint8	unused[6];
		udf_Uint8	fdscript;
		udf_Uint8	fdxflags;
		udf_Uint16	fdcomment;
		udf_Uint32	fdputaway;
	}	
	
	align(1) struct udf_finfo {
		udf_Uint32	fdtype;
		udf_Uint32	fdcreator;
		udf_Uint16	fdflags;
		udf_point	fdlocation;
		udf_Uint16	fdfldr;
	}
	
	align(1) struct udf_mac_file_finderinfo {
	/* 0*/	udf_Uint16	headerchecksum;
	/* 2*/	udf_Uint16	reserved;
	/* 4*/	udf_Uint32	parentdirid;
	/* 8*/	udf_finfo	fileinfo;
	/*24*/	udf_fxinfo	fileextinfo;
	/*40*/	udf_Uint32	resourcedatalength;
	/*44*/	udf_Uint32	resourcealloclength;
	/*48*/
	}
	
	align(1) struct udf_ext_attribute_file_macfinderinfo {
	/* 0*/	udf_Uint32	attribute_type;		/* = 2048 */
	/* 4*/	udf_Uint8	attribute_subtype;	/* = 1 */
	/* 5*/	udf_zerobyte	reserved[3];
	/* 8*/	udf_Uint32	attribute_length;	/* = 48 + 48 */
	/*12*/	udf_Uint32	impl_use_length;	/* = 48 */
	/*16*/	udf_EntityID	impl_ident;		/* "*UDF Mac FinderInfo" */
	/*48*/	udf_mac_file_finderinfo	finderinfo;
	/*96*/
	}
	
	align(1) struct udf_short_ad {			/* ECMA-167 4/14.14.1 */
	/*0*/	udf_Uint32	extent_length;
	/*4*/	udf_Uint32	extent_position;
	/*8*/
	}
	
	align(1) struct FileEntry { // 2.3.6 File Entry
		Tag          DescriptorTag;
		icbtag       ICBTag;
		u32          Uid;
		u32          Gid;
		Permission   Permissions;
		u16          FileLinkCount;
		u8           RecordFormat;
		u8           RecordDisplayAttributes;
		u32          RecordLength;
		u64          InformationLength;
		u64          LogicalBlocksRecorded;
		Timestamp    AccessTime;
		Timestamp    ModificationTime;
		Timestamp    AttributeTime;
		u32          Checkpoint;
		lb_addr      ExtendedAttributeICB;
		EntityID     ImplementationIdentifier;
		u64          UniqueID;
		u32          LengthofExtendedAttributes;
		u32          LengthofAllocationDescriptors;
		ExtendedAttributeHeaderDescriptor    ExtendedAttributeHeader;
		udf_ext_attribute_free_ea_space      ext_attribute_free_ea_space;
		udf_ext_attribute_dvd_cgms_info      ext_attribute_dvd_cgms_info;
		udf_ext_attribute_file_macfinderinfo ext_attribute_macfinderinfo;
		udf_short_ad AllocationDescriptors;
		
		enum Permission : u32 {
			// other
			OX = 1, // eXecute
			OW = 2, // Write
			OR = 4, // Read
			// group
			GX = 32,
			GW = 64,
			GR = 128,
			// user
			UX = 1024,
			UW = 2048,
			UR = 4096,			
		}
	}
	
	align(1) struct FileIdentifierDescriptor { // 2.3.4 File Identifier Descriptor
		Tag DescriptorTag;
		u16 FileVersionNumber;
		u8 FileCharacteristics;
		u8 LengthofFileIdentifier;
		long_ad ICB;
		u16 LengthOfImplementationUse;
		//u8 ImplementationUse[];
		//u8 FileIdentifier[];
		//u8 Padding[];
	}
	
	void setFileEntry() {
		bool is_directory = false;
	
		FileEntry fe;
		
		const uint UDF_ICBTAG_FLAG_MASK_AD_TYPE = 7;
		const uint UDF_ICBTAG_FLAG_SHORT_AD = 0;
		const uint UDF_ICBTAG_FLAG_DIRECTORY_SORT = 8;
		const uint UDF_ICBTAG_FLAG_NONRELOCATABLE = 16;
		const uint UDF_ICBTAG_FLAG_ARCHIVE = 32;
		const uint UDF_ICBTAG_FLAG_SETUID = 64;
		const uint UDF_ICBTAG_FLAG_SETGID = 128;
		const uint UDF_ICBTAG_FLAG_STICKY = 256;
		const uint UDF_ICBTAG_FLAG_CONTIGUOUS = 512;
		const uint UDF_ICBTAG_FLAG_SYSTEM = 1024;
		const uint UDF_ICBTAG_FLAG_TRANSFORMED = 2048;
		const uint UDF_ICBTAG_FLAG_MULTI_VERSIONS = 4096;
		const uint UDF_ICBTAG_FLAG_STREAM = 8192;

		fe.ICBTag.StrategyType = 4;
		fe.ICBTag.MaximumNumberofEntries = 1;
		fe.ICBTag.MaximumNumberofEntries = 1;
		fe.ICBTag.StrategyParameter = 0;
		fe.ICBTag.Flags = UDF_ICBTAG_FLAG_NONRELOCATABLE | UDF_ICBTAG_FLAG_ARCHIVE | UDF_ICBTAG_FLAG_CONTIGUOUS;

		fe.UniqueID = unique_id;

		fe.FileLinkCount = link_count;
		fe.Checkpoint = 1;

		fe.ICBTag.FileType = is_directory ? icbtag.file_type.Directory : icbtag.file_type.ByteSeq;
		fe.Gid = fe.Uid = -1;

		setImplementEID(fe.ImplementationIdentifier);

		// Read/Execute permissions for user, group & other
		// Read
		fe.permissions = FileEntry.Permission.OR | FileEntry.Permission.GR | FileEntry.Permission.UR;
		// eXecute
		if (is_directory) fe.permissions |= FileEntry.Permission.OX | FileEntry.Permission.GX | FileEntry.Permission.UX;
		
		fe.InformationLength = length;
		fe.LogicalBlocksRecorded = iso.getSectors(length);
		fe.AccessTime       = StartedDateAndTime;
		fe.ModificationTime = StartedDateAndTime;
		fe.AttributeTime    = StartedDateAndTime;
		
	}
	
/*static void
set_file_entry(buf, rba, file_rba, length, iso_date, is_directory, link_count, unique_id)
	unsigned char	*buf;
	unsigned	rba;
	unsigned	file_rba;
	unsigned	length;
	const char	*iso_date;
	int		is_directory;
	unsigned	link_count;
	unsigned	unique_id;
{
	udf_short_ad	*allocation_desc;
	unsigned	chunk;

	udf_file_entry *fe = (udf_file_entry *)buf;

	//set32(&fe->icb_tag.prior_recorded_number_of_direct_entries, 0);
	
	//set16(&;
	//fe->icb_tag.parent_icb_location;



	//fe->ext_attribute_icb;
	//Extended attributes that may (?) be required for DVD-Video
	//compliance

	//set32(&fe->length_of_ext_attributes, 0);

	allocation_desc = &fe->allocation_desc;
	//* Only a file size less than 1GB can be expressed by a single
	//* AllocationDescriptor. When the size of a file is larger than 1GB,
	//* 2 or more AllocationDescriptors should be used. We don't know
	//* whether a singl 8-byte AllocationDescriptor should be written or no
	//* one should be written if the size of a file is 0 byte. - FIXME.
	//*
	//* XXX We get called with buf[2048]. This allows a max. file size of
	//* XXX 234 GB. With more we would cause a buffer overflow.
	//* XXX We need to check whether UDF would allow files > 234 GB.
	for (; length > 0; length -= chunk) {
		chunk = (length > 0x3ffff800) ? 0x3ffff800 : length;
		set32(&allocation_desc->extent_length, chunk);
		set32(&allocation_desc->extent_position, file_rba);
		file_rba += chunk >> 11;
		allocation_desc++;
	}
	set32(&fe->length_of_allocation_descs,
				(unsigned char *) allocation_desc -
				(unsigned char *) &fe->allocation_desc);
	set_tag(&fe->desc_tag, UDF_TAGID_FILE_ENTRY, rba,
		(unsigned char *) allocation_desc - buf);
}*/
		
	align(1) struct extent_ad {
		u32 extent_length;
		u32 extent_location;
		
		static extent_ad opCall(u32 location, u32 length) {
			extent_ad e;
			e.extent_length = length;
			e.extent_location = location;
			return e;
		}
	}
	
	align(1) struct lb_addr {
		u32 logical_block_number;
		u16 partition_reference_number;
	}	
	
	align(1) struct long_ad { // 2.3.10.1 Long Allocation Descriptor
		u32	    ExtentLength;
		lb_addr	ExtentLocation;
		u16     flags;
		u32     unique_id;
	}	
	
	align(1) struct charspec {   // 2.1.2 OSTA CS0 Charspec
		u8 CharacterSetType;     // 0
		u8 CharacterSetInfo[63]; // "OSTA Compressed Unicode"
		
		void set() {
			CharacterSetType = 0;
			setStringz(CharacterSetInfo, "OSTA Compressed Unicode");
		}
	}
	
	align(1) struct EntityID {  // 2.1.5 Entity Identifier
		u8 Flags;               // 2.1.5.1 Uint8 Flags
		u8 Identifier[23];      // 2.1.5.2 char Identifier[23]
		u8 IdentifierSuffix[8]; // 2.1.5.3 char IdentifierSuffix[8]
	}
	
	align(1) struct Timestamp { // 2.1.4 Timestamp
		u16 TypeAndTimezone;    // 2.1.4.1 Uint16 TypeAndTimezone
		s16 Year;
		u8  Month;
		u8  Day;
		u8  Hour;
		u8  Minute;
		u8  Second;
		u8  Centiseconds;
		u8  HundredsofMicroseconds;
		u8  Microseconds;
		
		void opAssign(long time) {
			std.date.Date date;
			date.parse(std.date.toUTCString(time));
			Year   = date.year;
			Month  = date.month;
			Day    = date.day;
			Hour   = date.hour;
			Minute = date.minute;
			Second = date.second;
			Centiseconds = (date.ms / 100) % 10;
			HundredsofMicroseconds = (date.ms / 10) % 10;
			Microseconds = (date.ms / 1) % 10;
		}
	}	
	
	align(1) struct PrimaryVolumeDescriptor { // 2.2.2 Primary Volume Descriptor
		Tag       DescriptorTag;
		u32       VolumeDescriptorSequenceNumber;
		u32       PrimaryVolumeDescriptorNumber;
		u8        VolumeIdentifier[0x20];
		u16       VolumeSequenceNumber;
		u16       MaximumVolumeSequenceNumber;
		u16       InterchangeLevel;
		u16       MaximumInterchangeLevel;
		u32       CharacterSetList;
		u32       MaximumCharacterSetList;
		u8        VolumeSetIdentifier[0x80];
		charspec  DescriptorCharacterSet;
		charspec  ExplanatoryCharacterSet;
		extent_ad VolumeAbstract;
		extent_ad VolumeCopyrightNotice;
		EntityID  ApplicationIdentifier;
		Timestamp RecordingDateandTime;
		EntityID  ImplementationIdentifier;
		u8        ImplementationUse[64];
		u32       PredecessorVolumeDescriptorSequenceLocation;
		u16       Flags;
		u8        Reserved[22];
	}	
	
	align(1) struct ImpUseVolumeDescriptor { // 2.2.7 Implementation Use Volume Descriptor
		Tag		 DescriptorTag;
		uint     VolumeDescriptorSequenceNumber;
		EntityID ImplementationIdentifier;
		charspec LVICharset;
		u8       LogicalVolumeIdentifier[128];
		u8       LVInfo1[36];
		u8       LVInfo2[36];
		u8       LVInfo3[36];
		EntityID ImplementationID;
		u8       ImplementationUse[128];
	}

	align(1) struct PartitionDescriptor { // 2.2.14 Partition Descriptor
		Tag      DescriptorTag;
		u32      VolumeDescriptorSequenceNumber;
		u16      PartitionFlags;
		u16      PartitionNumber;
		EntityID PartitionContents;
		u8       PartitionContentsUse[128];
		u32      AccessType;
		u32      PartitionStartingLocation;
		u32      PartitionLength;
		EntityID ImplementationIdentifier;
		u8       ImplementationUse[128];
		u8       Reserved[156];
	}
	
	align(1) struct PartitionMapType1 {
		u8  Type;
		u8  Length;
		u16 VolumeSequenceNumber;
		u16 PartitionNumber;
	}
	
	align(1) struct LogicalVolumeDescriptor { // 2.2.4 Logical Volume Descriptor
		Tag       DescriptorTag;
		u32       VolumeDescriptorSequenceNumber;
		charspec  DescriptorCharacterSet;
		u8        LogicalVolumeIdentifier[128];
		u32       LogicalBlockSize;
		EntityID  DomainIdentifier;
		long_ad   LogicalVolumeContentsUse;
		u32       MapTableLength;
		u32       NumberofPartitionMaps;
		EntityID  ImplementationIdentifier;
		s8        ImplementationUse[128];
		extent_ad IntegritySequenceExtent;
		PartitionMapType1 PartitionMaps[1];
	}

	align(1) struct UnallocatedSpaceDesc { // 2.2.5 Unallocated Space Descriptor
		Tag       DescriptorTag;
		u32       VolumeDescriptorSequenceNumber;
		u32       NumberofAllocationDescriptors;
		//extent_ad AllocationDescriptors[];
	}
	
	align(1) struct TerminatingDescriptor { // ??
		Tag       DescriptorTag;
		ubyte     Reserved[496];
	}	
	
	align(1) struct LogicalVolumeHeaderDesc { // 3.2.1 Logical Volume Header Descriptor
		ulong UniqueID;
		ubyte Reserved[24];
	}

	align(1) struct LogicalVolumeIntegrityDesc { // 2.2.6 Logical Volume Integrity Descriptor
		Tag		   DescriptorTag;
		Timestamp  RecordingDateAndTime;
		uint       IntegrityType;
		extent_ad  NextIntegrityExtent;
		LogicalVolumeHeaderDesc	LogicalVolumeContentsUse;
		uint       NumberOfPartitions;
		uint       LengthOfImplementationUse;
		uint       FreeSpaceTable;
		uint       SizeTable;
		EntityID   ImplementationID;
		uint       NumberofFiles;
		uint       NumberofDirectories;
		ushort     MinimumUDFReadRevision;
		ushort     MinimumUDFWriteRevision;
		ushort     MaximumUDFWriteRevision;
	}
	
	align(1) struct AnchorVolumeDescriptorPointer { // 2.2.3 Anchor Volume Descriptor Pointer
		Tag        DescriptorTag;
		extent_ad  MainVolumeDescriptorSequenceExtent;
		extent_ad  ReserveVolumeDescriptorSequenceExtent;
		ubyte      Reserved[480];
	}
	
	// 2.3.5 ICB Tag

	align(1) struct FileSetDescriptor { // 2.3.2 File Set Descriptor
		Tag       DescriptorTag;
		Timestamp RecordingDateAndTime;
		u16       InterchangeLevel;
		u16       MaximumInterchangeLevel;
		u32       CharacterSetList;
		u32       MaximumCharacterSetList;
		u32       FileSetNumber;
		u32       FileSetDescriptorNumber;
		charspec  LogicalVolumeIdentifierCharacterSet;
		u8        LogicalVolumeIdentifier[128];
		charspec  FileSetCharacterSet;
		u8        FileSetIdentifier[32];
		u8        CopyrightFileIdentifier[32];
		u8        AbstractFileIdentifier[32];
		long_ad   RootDirectoryICB;
		EntityID  DomainIdentifier;
		long_ad   NextExtent;
		long_ad   SystemStreamDirectoryICB;
		u8        Reserved[32];
	}
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
	
	static ushort crc(ubyte *buf, uint len) {
		const uint poly = 0x11021;
		static ushort lookup[256];
		uint r;

		if (lookup[1] == 0) {
			for (uint j = 0; j < 256; ++j) {
				uint temp = j << 8;
				for (uint k = 0; k < 8; ++k) {
					uint hibit = temp & 0x8000;
					temp <<= 1;
					if (hibit) temp ^= poly;
				}
				lookup[j] = temp;
			}
		}
		
		r = 0;
		for (uint i = 0; i < len; ++i) r = (r << 8) ^ lookup[((r >> 8) ^ buf[i]) & 0xFF];

		return (r & 0xFFFF);
	}	

	static void TagSet(Tag *t, Tag.ID id, uint lba, int crc_length) {
		t.TagIdentifier = id;
		t.DescriptorVersion = 2;
		t.DescriptorCRC = crc((cast(ubyte *)t) + 16, crc_length - 16);
		t.DescriptorCRCLength = crc_length - 16;
		t.TagLocation = lba;
		t.TagChecksum = 0;
		for (int n = 0; n < 16; n++) t.TagChecksum += (cast(ubyte *)t)[n];		
	}
	
	void setImplementEID(out EntityID e) {
		e.Flags = 0;
		setStringz(e.Identifier, "*D ISO UTIL");
	}

	void setDomainIdent(out EntityID e) {
		e.Flags = 0;
		setStringz(e.Identifier, "*OSTA UDF Compliant");
		e.IdentifierSuffix[0..3] = [2, 1, 3];
	}
	
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

	this(ISO iso) {
		this.iso = iso;
		StartedDateAndTime = getUTCtime();
	}

	void writeFragmentVolumeRecognitionArea() {
		// BegginingExtendedAreaDescriptor (BEA01)
		// NSRDescriptor (NSR02)
		// TerminatingExtendedAreaDescriptor (TEA01)
		foreach (id; ["BEA01", "NSR02", "TEA01"]) {
			ISO.VolumeDescriptor vd;
			vd.type = ISO.VolumeDescriptor.Type.BootRecord;
			setStringz(vd.id, id);
			vd.ver = 1;
			iso.writeSector(TA(vd));
		}

		iso.writeEmptySector(11);
	}
	
	// Sector padding
	void writeFragmentPADto(int sector) { while (iso.lba < sector) iso.writeEmptySector(); }
	
	void writeTerminatingDescriptor() {
		TerminatingDescriptor td;
		TagSet(&td.DescriptorTag, Tag.ID.TerminatingDescriptor, iso.lba, 512);
		iso.writeSector(TA(td));
	}
	
	void writeLogicalVolumeIntegrityDesc() {
		LogicalVolumeIntegrityDesc lvid;

		lvid.RecordingDateAndTime = StartedDateAndTime;
		setImplementEID(lvid.ImplementationID);
		
		lvid.LogicalVolumeContentsUse.UniqueID = lba_last_file_entry + 1;
		lvid.IntegrityType             = 1;
		lvid.NumberOfPartitions        = 1;
		lvid.LengthOfImplementationUse = 46;
		lvid.SizeTable                 = lba_end_anchor_vol_desc - lba_udf_partition_start;
		lvid.NumberofFiles             = num_udf_files;
		lvid.NumberofDirectories       = num_udf_directories;
		lvid.MinimumUDFReadRevision    = 0x102;
		lvid.MinimumUDFWriteRevision   = 0x102;
		lvid.MaximumUDFWriteRevision   = 0x102;

		
		TagSet(&lvid.DescriptorTag, Tag.ID.LogicalVolumeIntegrityDesc, iso.lba, 88 + 46);
		iso.writeSector(TA(lvid));
	}	

	void writeFragmentIntegrity() {
		writeLogicalVolumeIntegrityDesc();
		writeTerminatingDescriptor();
	}

	void writeAnchorVolumeDescriptorPointer() {
		static const int UDF_MAIN_SEQ_LENGTH = 16;
		
		// Information about the MainVolumeDescriptor and the copy (for redudancy)
		
		AnchorVolumeDescriptorPointer avdp;
		
		avdp.MainVolumeDescriptorSequenceExtent    = extent_ad(lba_main_seq     , ISO.SECTOR_SIZE * UDF_MAIN_SEQ_LENGTH);
		avdp.ReserveVolumeDescriptorSequenceExtent = extent_ad(lba_main_seq_copy, ISO.SECTOR_SIZE * UDF_MAIN_SEQ_LENGTH);

		TagSet(&avdp.DescriptorTag, Tag.ID.AnchorVolumeDescriptorPointer, iso.lba, 512);
		iso.writeSector(TA(avdp));
	}
	
	void writeFragmentFileSetDescriptor() {
		writeFileSetDescriptor();
		writeTerminatingDescriptor();		
	}
	
	void writeFileSetDescriptor() {
		FileSetDescriptor fsd;
		
		fsd.RecordingDateAndTime = StartedDateAndTime;

		fsd.InterchangeLevel = 3;
		fsd.MaximumInterchangeLevel = 3;
		
		fsd.CharacterSetList = 1;
		fsd.MaximumCharacterSetList = 1;
		
		fsd.LogicalVolumeIdentifierCharacterSet.set();
		setStringz(fsd.LogicalVolumeIdentifier, iso.VolumeId);
		
		fsd.FileSetCharacterSet.set();
		setStringz(fsd.FileSetIdentifier, iso.VolumeId);

		fsd.RootDirectoryICB.ExtentLength = ISO.SECTOR_SIZE;
		fsd.RootDirectoryICB.ExtentLocation.logical_block_number = udf_file_entry_sector - lba_udf_partition_start;
		setDomainIdent(fsd.DomainIdentifier);
		
		TagSet(&fsd.DescriptorTag, Tag.ID.FileSetDescriptor, iso.lba, 512);
		iso.writeSector(TA(fsd));
	}
	
	void writeLogicalVolumeDescriptor() {
		LogicalVolumeDescriptor lvd;
		
		lvd.VolumeDescriptorSequenceNumber = 3;
		lvd.DescriptorCharacterSet.set();
		setStringz(lvd.LogicalVolumeIdentifier, iso.VolumeId);
		lvd.LogicalBlockSize = ISO.SECTOR_SIZE;
		setDomainIdent(lvd.DomainIdentifier);
		lvd.LogicalVolumeContentsUse.ExtentLength = ISO.SECTOR_SIZE * 2;
		
		lvd.MapTableLength = 6;
		lvd.NumberofPartitionMaps = 1;
		setImplementEID(lvd.ImplementationIdentifier);
		lvd.IntegritySequenceExtent = extent_ad(lba_integ_seq, ISO.SECTOR_SIZE * 2);
		lvd.PartitionMaps[0].Type = 1;
		lvd.PartitionMaps[0].Length = 6;
		lvd.PartitionMaps[0].VolumeSequenceNumber = 1;
		
		TagSet(&lvd.DescriptorTag, Tag.ID.LogicalVolumeDescriptor, iso.lba, 446);
		iso.writeSector(TA(lvd));
	}	
	
	void writeUnallocatedSpaceDesc() { // 2.2.5 Unallocated Space Descriptor
		UnallocatedSpaceDesc usd;
		usd.VolumeDescriptorSequenceNumber = 4;
		TagSet(&usd.DescriptorTag, Tag.ID.UnallocatedSpaceDesc, iso.lba, 24);
		iso.writeSector(TA(usd));
	}
	
	void writePartitionDescriptor() { // 2.2.14 Partition Descriptors
		PartitionDescriptor pvd;
		pvd.VolumeDescriptorSequenceNumber = 2;
		pvd.PartitionFlags = 1;
		pvd.PartitionContents.Flags = 2;
		setStringz(pvd.PartitionContents.Identifier, "+NSR02");
		pvd.AccessType = 1;
		pvd.PartitionStartingLocation = lba_udf_partition_start;
		pvd.PartitionLength = lba_end_anchor_vol_desc - lba_udf_partition_start;
		
		setImplementEID(pvd.ImplementationIdentifier);
		
		TagSet(&pvd.DescriptorTag, Tag.ID.PartitionDescriptor, iso.lba, 512);
		iso.writeSector(TA(pvd));
	}
	
	void writeImpUseVolumeDescriptor() { // 2.2.7 Implementation Use Volume Descriptor
		ImpUseVolumeDescriptor iuvd;
		iuvd.VolumeDescriptorSequenceNumber = 1;
		setStringz(iuvd.ImplementationIdentifier.Identifier, "*UDF LV Info");
		iuvd.ImplementationIdentifier.IdentifierSuffix[0] = 2;
		iuvd.ImplementationIdentifier.IdentifierSuffix[0] = 1;
		iuvd.LVICharset.set();
		setStringz(iuvd.LogicalVolumeIdentifier, iso.VolumeId);
		setImplementEID(iuvd.ImplementationID);
		
		TagSet(&iuvd.DescriptorTag, Tag.ID.ImpUseVolumeDescriptor, iso.lba, 512);
		iso.writeSector(TA(iuvd));
	}
	
	void writePrimaryVolumeDescriptor() {
		PrimaryVolumeDescriptor pvd;
		
		setStringz(pvd.VolumeIdentifier, iso.VolumeId);
		pvd.VolumeSequenceNumber = 1;
		pvd.MaximumVolumeSequenceNumber = 1;
		pvd.InterchangeLevel = 2;
		pvd.MaximumInterchangeLevel = 2;
		pvd.CharacterSetList = 1;
		pvd.MaximumCharacterSetList = 1;
		setStringz(pvd.VolumeSetIdentifier[0x00..0x10], std.string.format("%016X", StartedDateAndTime));
		setStringz(pvd.VolumeSetIdentifier[0x10..0x80], iso.VolumeSetId);
		pvd.DescriptorCharacterSet.set();
		pvd.ExplanatoryCharacterSet.set();
		setImplementEID(pvd.ImplementationIdentifier);
		pvd.RecordingDateandTime = StartedDateAndTime;
	
		TagSet(&pvd.DescriptorTag, Tag.ID.PrimaryVolumeDescriptor, iso.lba, 512);
		iso.writeSector(TA(pvd));
	}
	
	void writeFragmentMainSec() { // 16 sectors
		writePrimaryVolumeDescriptor(); //
		writeImpUseVolumeDescriptor();  //
		writePartitionDescriptor();     //
		writeLogicalVolumeDescriptor(); //
		writeUnallocatedSpaceDesc();    //
		writeTerminatingDescriptor();   //
		iso.writeEmptySector(10);       //
	}
		
	void writeHeader() {
		iso.writeHeader();
		writeFragmentVolumeRecognitionArea(); // UDF volume recognition area (3 sectors BEA01, NSR02, TEA01)
		writeFragmentPADto(32); // UDF pad to sector 32
		lba_main_seq      = iso.lba; writeFragmentMainSec(); // MAIN ; UDF main seq (16 sectors)
		lba_main_seq_copy = iso.lba; writeFragmentMainSec(); // RSRV ; UDF second seq (16 sectors) (Copy; redundance)
		lba_integ_seq     = iso.lba; writeFragmentIntegrity(); // UDF integ seq
		writeFragmentPADto(256);  // UDF pad to sector 256
		writeAnchorVolumeDescriptorPointer(); // UDF Anchor volume
		writeFragmentFileSetDescriptor();     // UDF file set
	}
	
	void writeFooter() {
		// lba_end_anchor_vol_desc
		writeAnchorVolumeDescriptorPointer();
	}	
	
	void finish() {
		writeFooter();
		iso.finish();
	}
}