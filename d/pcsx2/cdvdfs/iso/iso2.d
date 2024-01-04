module iso2;

import iso;
import udf;

class Entry {
	ulong uid;
	char[] name;
	long time;
	bool hidden, directory, system; // Boolean attributes
	Entry parent;
	Entry[] childs;
	Entry[] directoryChilds() { Entry[] r; foreach (e; childs) if (e.directory) r ~= e; return r; }
	protected ISO _iso;
	ISO iso(ISO i) {
		dr.VolumeSequenceNumber = ++i.fileCount;
		return (_iso = i);
	}
	ISO iso() { return _iso; }

	protected UDF _udf;
	UDF udf(UDF u) {
		if (directory) u.num_udf_directories++; else u.num_udf_files++;
		return (_udf = u);
	}
	UDF udf() { return _udf; }

	bool processed = false;
	
	// DirectoryRecord for ISO 9660
	ISO.DirectoryRecord* dr; // DirectoryRecord
	Stream[] drsl; // SliceStreams to write DR
	void drslUpdate() { // Write DR to streams
		//writefln("[%s:%d] : %08X:%08X", name, drsl.length, dr.Extent.l, dr.Size.l);
		foreach (drs; drsl) {
			ubyte[] data = TA(*dr);
			drs.position = 1;
			drs.write(data[1..data.length - 1]);
		}
	}
	void drPut(bool useName = true) {
		drsl ~= iso.drPut(*dr, useName ? name : "\0");
		//writefln("[%s:%d] : %08X:%08X", name, drsl.length, dr.Extent.l, dr.Size.l);
	}
	
	void drPutAll() {
		processed = true; {
			dr.Extent = iso.lba;
			ulong start = iso.s.position;

			this.drPut(false); // Put current "."
			parent.drPut(false); // Put parent ".."
			
			foreach (ce; childs) ce.drPut();
			iso.finalizeSector();
			
			dr.Size = iso.s.position - start;
			drslUpdate();
			
			foreach (ce; directoryChilds) if (!ce.processed) ce.drPutAll();
		} processed = false;
	}
	
	this(char[] name, bool directory, Entry parent, ISO iso = null, ISO.DirectoryRecord* dr =  null) {
		this.directory = directory;
		this.name = name;
		this.parent = parent ? parent : this;
		if (!iso) iso = parent.iso;
		if (dr == null) dr = new ISO.DirectoryRecord;
		this.dr = dr;
		this.iso = iso;
		if (directory) dr.Flags |= (1 << 1);
		dr.Length = (*dr).sizeof + name.length;
		dr.NameLength = name.length;
		if (parent && parent.udf) udf = parent.udf;
	}
	
	// FileIdentifierDescriptor for UDF
	/*
	UDF.FileIdentifierDescriptor fid;
	Stream[] fidsl;
	void fidWrite() { foreach (fids; fidsl) fids.write(TA( fid)); foreach (c; name) write(cast(ushort)c); } // Write DR to streams
	*/
	
	void prepareRootDr() {
		ulong start = 0x800 * 0x10 + 156;
		drsl ~= new SliceStream(iso.s, start, start + ISO.DirectoryRecord.sizeof);
		dr.date = getUTCtime();
		dr.Length = (*dr).sizeof + 1;
		dr.NameLength = 1;
	}
	
	void opCatAssign(Entry e) {
		childs ~= e;
	}
	
/*
	udf_short_ad	*allocation_desc;
	unsigned	chunk;
	unsigned short	checksum;
	int		i;
	unsigned char *p;
	unsigned short	flags;
	short	macflags;

	udf_file_entry *fe = (udf_file_entry *)buf;



	set32(&fe->ext_attribute_header.impl_attributes_location, sizeof (udf_ext_attribute_header_desc));
	set32(&fe->ext_attribute_header.application_attributes_location, sizeof (udf_ext_attribute_header_desc) +
		sizeof (udf_ext_attribute_free_ea_space) + sizeof (udf_ext_attribute_dvd_cgms_info) +
		sizeof (udf_ext_attribute_file_macfinderinfo));
	set_tag(&fe->ext_attribute_header.desc_tag, UDF_TAGID_EXT_ATTRIBUTE_HEADER_DESC, rba,
		sizeof (udf_ext_attribute_header_desc));


	set32(&fe->ext_attribute_dvd_cgms_info.attribute_type, SECTOR_SIZE);
	set8(&fe->ext_attribute_dvd_cgms_info.attribute_subtype, 1);
	set32(&fe->ext_attribute_dvd_cgms_info.attribute_length, 56);
	set32(&fe->ext_attribute_dvd_cgms_info.impl_use_length, 8);
	strcpy((char *)fe->ext_attribute_dvd_cgms_info.impl_ident.ident, "*UDF DVD CGMS Info");
	fe->ext_attribute_dvd_cgms_info.impl_ident.ident_suffix[0] = 2;
	fe->ext_attribute_dvd_cgms_info.impl_ident.ident_suffix[1] = 1;

	for (i = 0, checksum = 0, p = (unsigned char *)&fe->ext_attribute_dvd_cgms_info; i < 48; i++)
		checksum += *p++;
	set16(&fe->ext_attribute_dvd_cgms_info.header_checksum, checksum);

	set32(&fe->ext_attribute_macfinderinfo.attribute_type, EXTATTR_IMP_USE);
	set8(&fe->ext_attribute_macfinderinfo.attribute_subtype, 1);
	set32(&fe->ext_attribute_macfinderinfo.attribute_length, 96);
	set32(&fe->ext_attribute_macfinderinfo.impl_use_length, 48);
	strcpy((char *)fe->ext_attribute_macfinderinfo.impl_ident.ident, "*UDF Mac FinderInfo");
	fe->ext_attribute_macfinderinfo.impl_ident.ident_suffix[0] = 2;
	fe->ext_attribute_macfinderinfo.impl_ident.ident_suffix[1] = 1;

	for (i = 0, checksum = 0, p = (unsigned char *)&fe->ext_attribute_macfinderinfo; i < 48; i++)
		checksum += *p++;
	set16(&fe->ext_attribute_macfinderinfo.finderinfo.headerchecksum, checksum);

	if (hfs_ent) {
		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdtype.l = hfs_ent->u.file.type[3];
		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdtype.ml = hfs_ent->u.file.type[2];
		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdtype.mh = hfs_ent->u.file.type[1];
		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdtype.h = hfs_ent->u.file.type[0];

		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdcreator.l = hfs_ent->u.file.creator[3];
		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdcreator.ml = hfs_ent->u.file.creator[2];
		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdcreator.mh = hfs_ent->u.file.creator[1];
		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdcreator.h = hfs_ent->u.file.creator[0];

		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdflags.l = ((char *)&macflags)[1];
		fe->ext_attribute_macfinderinfo.finderinfo.fileinfo.fdflags.h = ((char *)&macflags)[0];

#ifdef INSERTMACRESFORK
		set32(&fe->ext_attribute_macfinderinfo.finderinfo.resourcedatalength, hfs_ent->u.file.rsize);
		set32(&fe->ext_attribute_macfinderinfo.finderinfo.resourcealloclength, hfs_ent->u.file.rsize);
#endif
	}

	allocation_desc = &fe->allocation_desc;

	for (; length > 0; length -= chunk) {
		chunk = (length > 0x3ffff800) ? 0x3ffff800 : length;
		set32(&allocation_desc->extent_length, chunk);
		set32(&allocation_desc->extent_position, file_rba);
		file_rba += chunk >> 11;
		allocation_desc++;
	}
	if (((Uchar *)allocation_desc) > &buf[2048])
		udf_size_panic(allocation_desc - &fe->allocation_desc);

	set32(&fe->length_of_allocation_descs,
				(unsigned char *) allocation_desc -
				(unsigned char *) &fe->allocation_desc);
	set_tag(&fe->desc_tag, UDF_TAGID_FILE_ENTRY, rba,
		(unsigned char *) allocation_desc - buf);
}
*/	
	
	void putFileEntry() {
		ushort checksum(ubyte[] v) { ushort r; foreach (c; v); r += c; return r; }
	
		udf_file_entry fe;
		
		fe.length_of_ext_attributes = 0;
		fe.icb_tag.strategy_type = 4;
		fe.icb_tag.maximum_number_of_entries = 1;
		fe.icb_tag.file_type = UDF_ICBTAG_FILETYPE_BYTESEQ;
		
		fe.icb_tag.flags = UDF_ICBTAG_FLAG_NONRELOCATABLE | UDF_ICBTAG_FLAG_ARCHIVE | UDF_ICBTAG_FLAG_CONTIGUOUS;

		fe.permissions = UDF_FILEENTRY_PERMISSION_OR | UDF_FILEENTRY_PERMISSION_GR | UDF_FILEENTRY_PERMISSION_UR;
		if (directory) fe.permissions |= UDF_FILEENTRY_PERMISSION_OX | UDF_FILEENTRY_PERMISSION_GX | UDF_FILEENTRY_PERMISSION_UX;
		
		fe.gid = fe.uid = -1;
		
		fe.file_link_count = link_count;
		fe.info_length = length;
		fe.logical_blocks_recorded = iso.getSectors(length);

		fe.access_time       = udf.StartedDateAndTime;
		fe.modification_time = udf.StartedDateAndTime;
		fe.attribute_time    = udf.StartedDateAndTime;

		fe.checkpoint = 1;
		
		setImplementEID(fe.impl_ident);
		fe.unique_id = uid;

		/*
		// ext_attribute_free_ea_space
		fe.length_of_ext_attributes |= udf_ext_attribute_free_ea_space.sizeof;
		fe.ext_attribute_free_ea_space.attribute_type    = ISO.SECTOR_SIZE;
		fe.ext_attribute_free_ea_space.attribute_subtype = 1;
		fe.ext_attribute_free_ea_space.attribute_length  = 52;
		fe.ext_attribute_free_ea_space.impl_use_length   = 4;
		setStringz(fe.ext_attribute_free_ea_space.impl_ident.ident, "*UDF FreeEASpace");
		fe.ext_attribute_free_ea_space.impl_ident.ident_suffix[0] = 2;
		fe.ext_attribute_free_ea_space.impl_ident.ident_suffix[1] = 1;
		fe.ext_attribute_free_ea_space.header_checksum = checksum((cast(ubyte*)&fe.ext_attribute_free_ea_space)[0..48]);
		*/
		
	}
	
	void putFileIdentDesc(bool useParent = false) {
		ubyte[0x800] buf;
		udf_file_ident_desc *fid = cast(udf_file_ident_desc *)buf.ptr;
		char[] name = this.name;
		if (useParent) name = "";
		
		fid.file_version_number = 1;
		fid.file_characteristics = 0;
		if (directory) fid.file_characteristics |= UDF_FILE_CHARACTERISTIC_DIRECTORY;
		if (useParent) fid.file_characteristics |= UDF_FILE_CHARACTERISTIC_PARENT;
		
		fid.icb.extent_length = ISO.SECTOR_SIZE;
		fid.icb.extent_location.logical_block_number = iso.lba;
		fid.icb.extent_location.partition_reference_number = 0;
		fid.icb.impl_use.unique_id = uid;
		fid.length_of_impl_use = 0;
		fid.length_of_file_ident = name.length;
		
		if (name) {
			fid.file_ident[0] = 8;
			(cast(char *)(fid.file_ident.ptr + 1))[0..name.length] = name;
		}
		
		int elength = 38 + 1 + fid.length_of_file_ident;
		while (elength % 4) buf[elength++] = 0;
		
		udf.TagSet(&fid.desc_tag, UDF_TAGID_FILE_IDENT_DESC, iso.lba, elength);
		iso.s.write(buf[0..elength]);
	}
	
	void udfPutAll() {
		this.putFileIdentDesc(true);   // .
		parent.putFileIdentDesc(true); // ..
		foreach (c; childs) c.putFileIdentDesc(false);
		iso.finalizeSector();
	}
}

void updateDir(Entry e, char[] path) {
	foreach (cf; listdir(path)) {
		char[] cff = path ~ "/" ~ cf;
		bool directory = isdir(cff) != 0;
		writefln("%s", cff);
		Entry ce = new Entry(cf, directory, e);
		// e, cf, directory
		e ~= ce;
		if (directory) updateDir(ce, cff);
	}
}

int main(char[][] args) {
	UDF udf = new UDF(new ISO);
	udf.iso.s = new File("lol.iso", FileMode.OutNew);

	Entry root = new Entry("\0", true, null, udf.iso, &udf.iso.pvd.dr);
	root.udf = udf;
	root.prepareRootDr();
	updateDir(root, "../");
	
	//udf.writeHeader();
		//root.drPutAll();
		root.udfPutAll();
	//udf.finish();
	
	writefln("%d", udf.num_udf_files);
	writefln("%d", udf.num_udf_directories);
	
	return 0;
}