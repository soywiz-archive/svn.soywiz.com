import std.stdio, std.stream, std.file, std.utf;

class CryptStream : FilterStream {
	private static const char[] table = x"A593F7B56C635B4AA60AA8E0B3B959D21047FA4ACFD43D0744AC4B5E026D587F066D7AFA3156BB82FC136DF067F0BD8B32FC8B8650B279CA99D942F6BFA94EA4832F83EF28F35D3228D7411127420EBE257EF675F75F8C49F8261D23FCA4440885A3B99A3A816AE2941ECD4CDBF974F35195E21FAD229D0CCA5984EEA1A86331758FC5054D4A091AA7B0B8A86B5B16B31E09F78D5842D49C783B1E5D96FBD2A9B9BC4E384A946363C954AB2EBFB11D85F4A1DEC6E1085A806894947BC3E5BAF8BBF2FD391AA8A04462D44EE5BF42B0F23B263FD231BC5740042C8D4D10B043A4E1F87A12A3CEE746DAF648D55458F8815B61C1BA2FA6F265B3CAB2DD66A2943795986CCBCF4D60EF9A83420664391DBABC170D85C20D5476DC38AB32AB05D6393E987B6A856F34CA0842E381D82E4625C613CB3BD43BA5FBE93C1F54C91F303043C150F9AD7A8B5C8DFDD4";

	int offset;
	
	this(Stream s, int offset = 0) {
		super(s);
		this.offset = offset;
	}
	
	static void toggle(ubyte[] data, int offset = 0) {
		for (int n = 0; n < data.length; n++) data[n] ^= table[(n + offset) % table.length];
	}
	
	override size_t readBlock(void* result, size_t len) {
		int roffset = source.position + offset;
		size_t r = source.readBlock(result, len);
		toggle((cast(ubyte*)result)[0..len], roffset);
		return r;
	}

	override size_t writeBlock(void* result, size_t len) {
		int roffset = source.position + offset;
		size_t r = source.writeBlock(result, len);
		toggle((cast(ubyte*)result)[0..len], roffset);
		return r;
	}
}

int main(char[][] args) {
	Stream s;
	uint count;
	
	s = new File("UIStringTable.dat");
	s.read(count);
	
	if (count > 0x100000) {
		s.position = 0;
		s = new CryptStream(s);
		s.read(count);
	}
	
	while (!s.eof) {
		wchar[] text;
		uint id;
		s.read(id);
		text = cast(wchar[])s.readString(0x200);
		foreach (n, c; text) if (c == 0) { text.length = n; break; }
		writefln("%05d(%d): '%s'", id, count--, toUTF8(text));
	}
	return 0;
}