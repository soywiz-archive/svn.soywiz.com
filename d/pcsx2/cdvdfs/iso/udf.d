module udf;

public import iso;
public import udf_fs;

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

	udf_tag* TAG(void *ptr) { return cast(udf_tag*)ptr; }
	
	static void TagSet(udf_tag *t, udf_Uint16 id, uint lba, int crc_length) {
		t.tag_ident = id;
		t.desc_version = 2;
		t.desc_crc = udf_crc((cast(ubyte *)t) + 16, crc_length - 16);
		t.desc_crc_length = crc_length - 16;
		t.tag_location = lba;
		t.tag_checksum = 0;
		for (int n = 0; n < 16; n++) t.tag_checksum += (cast(ubyte *)t)[n];		
	}
	
	void setImplementEID(out udf_EntityID e) {
		e.flags = 0;
		setStringz(e.ident, "*D ISO UTIL");
	}

	void setDomainIdent(out udf_EntityID e) {
		e.flags = 0;
		setStringz(e.ident, "*OSTA UDF Compliant");
		e.ident_suffix[0..3] = [2, 1, 3];
	}
	
	void setCharspec(out udf_charspec c) {
		c.character_set_type = 0;
		setStringz(c.character_set_info, "OSTA Compressed Unicode");
	}
	
	this(ISO iso) {
		this.iso = iso;
		StartedDateAndTime = getUTCtime();
	}

	void writeUnallocatedSpaceDesc() { // 2.2.5 Unallocated Space Descriptor
		udf_unallocated_space_desc usd;
		usd.volume_desc_seq_number = 4;
		TagSet(&usd.desc_tag, UDF_TAGID_UNALLOCATED_SPACE_DESC, iso.lba, 24);
		iso.writeSector(TA(usd));
	}
	
	void writeLogicalVolumeDescriptor() {
		udf_logical_volume_desc lvd;
		
		lvd.volume_desc_seq_number = 3;
		
		setCharspec(lvd.desc_character_set);
		setStringz(lvd.logical_volume_ident, iso.VolumeId);
		
		lvd.logical_block_size = ISO.SECTOR_SIZE;
		setDomainIdent(lvd.domain_ident);
		lvd.logical_volume_contents_use.extent_length = ISO.SECTOR_SIZE * 2;
		
		lvd.map_table_length = 6;
		lvd.number_of_partition_maps = 1;
		setImplementEID(lvd.impl_ident);
		lvd.integrity_seq_extent = udf_extent_ad(lba_integ_seq, ISO.SECTOR_SIZE * 2);
		lvd.partition_map[0].partition_map_type = 1;
		lvd.partition_map[0].partition_map_length = 6;
		lvd.partition_map[0].volume_seq_number = 1;
		
		TagSet(&lvd.desc_tag, UDF_TAGID_LOGICAL_VOLUME_DESC, iso.lba, 446);
		iso.writeSector(TA(lvd));
	}
	
	void writePartitionDescriptor() { // 2.2.14 Partition Descriptors
		udf_partition_desc pvd;
		
		pvd.volume_desc_seq_number = 2;
		pvd.partition_flags = 1;
		pvd.partition_contents.flags = 2;
		setStringz(pvd.partition_contents.ident, "+NSR02");
		pvd.access_type = 1;
		pvd.partition_starting_location = lba_udf_partition_start;
		pvd.partition_length = lba_end_anchor_vol_desc - lba_udf_partition_start;
		
		setImplementEID(pvd.impl_ident);
		
		TagSet(&pvd.desc_tag, UDF_TAGID_PARTITION_DESC, iso.lba, 512);
		iso.writeSector(TA(pvd));
	}	
	
	void writePrimaryVolumeDescriptor() {
		udf_primary_volume_desc pvd;
		
		setStringz(pvd.volume_ident, iso.VolumeId);
		pvd.volume_seq_number = 1;
		pvd.maximum_volume_seq_number = 1;
		pvd.interchange_level = 2;
		pvd.maximum_interchange_level = 2;
		
		pvd.character_set_list = 1;
		pvd.maximum_character_set_list = 1;
		setStringz(pvd.volume_set_ident[0x00..0x10], std.string.format("%016X", StartedDateAndTime));
		setStringz(pvd.volume_set_ident[0x10..0x80], iso.VolumeSetId);
		
		setCharspec(pvd.desc_character_set);
		setCharspec(pvd.explanatory_character_set);
		
		setImplementEID(pvd.impl_ident);
		pvd.recording_date_and_time = StartedDateAndTime;
	
		TagSet(&pvd.desc_tag, UDF_TAGID_PRIMARY_VOLUME_DESC, iso.lba, 512);
		iso.writeSector(TA(pvd));
	}
	
	void writeImpUseVolumeDescriptor() { // 2.2.7 Implementation Use Volume Descriptor
		udf_impl_use_volume_desc iuvd;
		
		iuvd.volume_desc_seq_number = 1;
		setStringz(iuvd.impl_ident.ident, "*UDF LV Info");
		iuvd.impl_ident.ident_suffix[0] = 2;
		iuvd.impl_ident.ident_suffix[0] = 1;
		
		setCharspec(iuvd.impl_use.lvi_charset);
		setStringz(iuvd.impl_use.logical_volume_ident, iso.VolumeId);
		setImplementEID(iuvd.impl_use.impl_id);
		
		TagSet(&iuvd.desc_tag, UDF_TAGID_IMPL_USE_VOLUME_DESC, iso.lba, 512);
		iso.writeSector(TA(iuvd));
	}	

	void writeFragmentMainSec(bool primary = true) { // 16 sectors
		if (primary) lba_main_seq = iso.lba; else lba_main_seq_copy = iso.lba;
		
		writePrimaryVolumeDescriptor(); //
		writeImpUseVolumeDescriptor();  //
		writePartitionDescriptor();     //
		writeLogicalVolumeDescriptor(); //
		writeUnallocatedSpaceDesc();    //
		writeTerminatingDescriptor();   //
		iso.writeEmptySector(10);       //
	}

	// Sector padding
	void writeFragmentPADto(int sector) { while (iso.lba < sector) iso.writeEmptySector(); }

	void writeAnchorVolumeDescriptorPointer() {
		static const int UDF_MAIN_SEQ_LENGTH = 16;
		
		udf_anchor_volume_desc_ptr avdp;
		
		avdp.main_volume_desc_seq_extent    = udf_extent_ad(lba_main_seq     , ISO.SECTOR_SIZE * UDF_MAIN_SEQ_LENGTH);
		avdp.reserve_volume_desc_seq_extent = udf_extent_ad(lba_main_seq_copy, ISO.SECTOR_SIZE * UDF_MAIN_SEQ_LENGTH);

		TagSet(&avdp.desc_tag, UDF_TAGID_ANCHOR_VOLUME_DESC_PTR, iso.lba, 512);
		iso.writeSector(TA(avdp));
	}
	
	void writeFragmentFileSetDescriptor() {
		writeFileSetDescriptor();
		writeTerminatingDescriptor();		
	}	
	
	void writeTerminatingDescriptor() {
		udf_terminating_desc td;
		TagSet(&td.desc_tag, UDF_TAGID_TERMINATING_DESC, iso.lba, 512);
		iso.writeSector(TA(td));
	}

	void writeFileSetDescriptor() {
		udf_file_set_desc fsd;
		
		fsd.recording_date_and_time = StartedDateAndTime;

		fsd.interchange_level = 3;
		fsd.maximum_interchange_level = 3;
		
		fsd.character_set_list = 1;
		fsd.maximum_character_set_list = 1;
		
		setCharspec(fsd.logical_volume_ident_character_set);
		setStringz(fsd.logical_volume_ident, iso.VolumeId);
		
		setCharspec(fsd.file_set_character_set);
		setStringz(fsd.file_set_ident, iso.VolumeId);

		fsd.root_directory_icb.extent_length = ISO.SECTOR_SIZE;
		fsd.root_directory_icb.extent_location.logical_block_number = udf_file_entry_sector - lba_udf_partition_start;
		setDomainIdent(fsd.domain_ident);
		
		TagSet(&fsd.desc_tag, UDF_TAGID_FILE_SET_DESC, iso.lba, 512);
		iso.writeSector(TA(fsd));
	}
	
	void writeFragmentIntegrity() {
		lba_integ_seq = iso.lba;
		writeLogicalVolumeIntegrityDesc();
		writeTerminatingDescriptor();
	}	

	void writeLogicalVolumeIntegrityDesc() {
		udf_logical_volume_integrity_desc lvid;

		lvid.recording_date = StartedDateAndTime;
		setImplementEID(lvid.impl_use.impl_id);
		
		lvid.logical_volume_contents_use.unique_id = lba_last_file_entry + 1;
		lvid.integrity_type             = 1;
		lvid.number_of_partitions       = 1;
		lvid.length_of_impl_use         = 46;
		lvid.size_table                 = lba_end_anchor_vol_desc - lba_udf_partition_start;
		
		lvid.impl_use.number_of_files             = num_udf_files;
		lvid.impl_use.number_of_directories       = num_udf_directories;
		lvid.impl_use.minimum_udf_read_revision    = 0x102;
		lvid.impl_use.minimum_udf_write_revision   = 0x102;
		lvid.impl_use.maximum_udf_write_revision   = 0x102;

		
		TagSet(&lvid.desc_tag, UDF_TAGID_LOGICAL_VOLUME_DESC, iso.lba, 88 + 46);
		iso.writeSector(TA(lvid));
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
	
	void writeHeader() {
		iso.writeHeader();
		writeFragmentVolumeRecognitionArea(); // UDF volume recognition area (3 sectors BEA01, NSR02, TEA01)
		writeFragmentPADto(32); // UDF pad to sector 32
		writeFragmentMainSec(true ); // MAIN ; UDF main seq (16 sectors)
		writeFragmentMainSec(false); // RSRV ; UDF second seq (16 sectors) (Copy; redundance)
		writeFragmentIntegrity(); // UDF integ seq
		writeFragmentPADto(256);  // UDF pad to sector 256
		writeAnchorVolumeDescriptorPointer(); // UDF Anchor volume
		writeFragmentFileSetDescriptor();     // UDF file set
	}
	
	void writeFooter() {
		writeAnchorVolumeDescriptorPointer();
	}	
	
	void finish() {
		writeFooter();
		iso.finish();
	}
}