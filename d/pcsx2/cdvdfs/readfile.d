import isofs;
import std.stream, std.stdio, std.string, std.regexp, std.conv;

struct CSV {
	char[][] header;
	char[][][] list;
	
	int length() {
		return list.length;
	}
	
	int opApply(int delegate(ref char[][char[]]) dg) {
		int result = 0;

		for (int i = 0; i < length; i++) {
			auto v = opIndex(i);
			result = dg(v);
			if (result) break;
		}
		return result;
	}

	char[][char[]] opIndex(int index) {
		char[][char[]] r;
		for (int n = 0; n < header.length; n++) {
			r[header[n]] = (list[index].length > n) ? list[index][n] : "";
		}
		return r;
	}
}

CSV process_csv(Stream s) {
	CSV csv;
	
	char[][] processLine() {
		char[][] list;
		auto line = s.readLine;
		char c;
		char[] cur;
		void push() {
			if (!cur.length) return;
			list ~= cur;
			cur = "";
		}
		if (line.length >= 3 && line[0..3] == x"EFBBBF") {
			line = line[3..line.length];
		}
		for (int n = 0; n < line.length; n++) { c = line[n];
			switch (c) {
				case ',':
					push();
				break;
				case '"':
					for (n++; n < line.length; n++) { c = line[n];
						//if (c == '\\') { cur ~= line[++n]; continue; }
						if (c == '"') break;
						cur ~= c;
					}
				break;
				default:
					cur ~= c;
				break;
			}
		}
		push();
		return list;
	}
	
	csv.header = processLine;
	while (!s.eof) {
		csv.list ~= processLine;
	}
	
	return csv;
}

void main(char[][] args) {
	enum Mode { FULL, SMART, SIMPLE }
	Mode mode = Mode.FULL;
	auto csv = process_csv(new BufferedFile("LogFile.CSV"));
	
	if (args.length > 1) {
		switch (args[1]) {
			case "full"  : mode = Mode.FULL; break;
			case "simple": mode = Mode.SIMPLE; break;
			case "smart" : mode = Mode.SMART; break;
			default:
				writefln("Unknown option: '%s'", args[1]);
				return;
			break;
		}
	} else {
		writefln("Specify a mode for processing [full|simple|smart]");
		return;
	}
	//writefln(args); return;
	
	Iso[char[]] cached_isos;
	Iso getIso(char[] name) {
		if ((name in cached_isos) is null) {
			cached_isos[name] = new Iso(new StreamConvertTo2048(new File(name)));
		}
		return cached_isos[name];
	}
	
	char[] last_file;
	long smart_last_offset;
	long smart_first_offset = -1, smart_length;
	
	foreach (line; csv) {
		if (line["Operation"] == "ReadFile") {
			auto detail = line["Detail"];
			long offset, length;
			foreach(m; RegExp(r"Offset: ([\d\.]+), Length: ([\d\.]+)").search(detail)) {
				char[] s_offset = m.match(1).replace(".", "");
				char[] s_length = m.match(2).replace(".", "");
				offset = std.conv.toInt(s_offset);
				length = std.conv.toInt(s_length);
			}
			try {
				auto iso = getIso(line["Path"]);
				if (iso !is null) {
					long sector = offset / 2352;
					auto file = iso.locateFile(sector);
					long roffset = offset - (file.dr.Extent & 0xFFFFFFFF) * 2352;

					if (mode == Mode.SMART) {
						if (last_file != file.name || !(smart_first_offset <= roffset && roffset <= smart_last_offset)) {
							if (smart_first_offset != -1) {
								writefln("%s : %d, %d", line["Time of Day"], smart_first_offset, smart_length);
							}
							smart_first_offset = roffset;
							smart_length = 0;
						}
					}
					
					smart_last_offset = roffset + length;
					smart_length += length;
					
					if (last_file != file.name) {
						if (mode != Mode.SIMPLE) writefln();
						writefln("    %s", file.name);
						smart_last_offset = -1;
					}
					if (mode == Mode.FULL) {
						writefln("%s : %d, %d", line["Time of Day"], roffset, length);
					}
					
					last_file = file.name;
				}
			} catch (Exception e) {
				writefln("ERROR: %s", e.toString);
			}
		}
	}
}