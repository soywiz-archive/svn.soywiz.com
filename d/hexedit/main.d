import std.string;
import std.stdio;
import std.stream;
import std.thread;
import std.c.time;

import dfl.all, dfl.internal.winapi, dfl.internal.utf;

import hexedit;

class MainForm : Form {
	//mixin ControlResizableGraphicsBuffer;

	this() {				
		// Initialize some of this Form's properties.
		width = 640;
		height = 480;
		startPosition = FormStartPosition.CENTER_SCREEN;
		//formBorderStyle = FormBorderStyle.FIXED_DIALOG; // Don't allow resize.
		//maximizeBox = false;
		text = "DFL Beginner Example"; // Form's caption text.
		
		HexComponent h;

		with (h = new HexComponent()) {
			parent = this;
			width = 320;
			height = 240;
			dock = DockStyle.FILL;
		}
	}
}


int main() {
	int result = 0;

	try {		
		Application.run(new MainForm);
	} catch(Object o) {
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		result = 1;
	}

	return result;
}
