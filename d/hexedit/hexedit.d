module hexedit;

import std.string;
import std.stdio;
import std.stream;
import std.thread;
import std.c.time;

import dfl.all, dfl.internal.winapi, dfl.internal.utf;

const int GRAPHICS_BUFFER_MINIMUM_SIZE = 256;
const int GRAPHICS_BUFFER_AUTO_GAIN = 50;


private uint _round2power(uint x)
{
	if(!x)
		return 1;
	uint z = 1 << std.intrinsic.bsr(x);
	if(x == z)
		return x;
	return z << 1;
}


/// Resizable graphics buffer.
struct ResizableGraphicsBuffer
{
	/// Start the graphics buffer with its initialial dimensions. The initial bits of the graphics buffer are undefined.
	void start(int width, int height)
	{
		assert(gbuf is null);
		rwidth = width;
		rheight = height;
		_bestSize(width, height);
		gbuf = new MemoryGraphics(width, height);
	}
	
	
	/// ditto
	void start(Size size)
	{
		return start(size.width, size.height);
	}
	
	
	/// Get the graphics buffer's Graphics to draw on.
	Graphics graphics() // getter
	{
		return gbuf;
	}
	
	
	/// Copy the graphics buffer bits to the provided Graphics.
	bool copyTo(Graphics g)
	{
		return gbuf.copyTo(g, 0, 0, rwidth, rheight);
	}
	
	
	/// ditto
	bool copyTo(Graphics g, Rect clipRect)
	{
		return gbuf.copyTo(g, clipRect.x, clipRect.y, clipRect.width, clipRect.height,
			clipRect.x, clipRect.y);
	}
	
	
	/// Stop the graphics buffer by releasing resources.
	void stop()
	{
		if(gbuf)
		{
			gbuf.dispose();
			gbuf = null;
		}
	}
	
	
	/// Update the dimensions of the graphics buffer.
	/// Returns: true if the entire area needs to be redrawn and the bits of the graphics buffer are undefined.
	bool resize(int width, int height)
	{
		rwidth = width;
		rheight = height;
		
		if(rwidth > gbuf.width || rheight > gbuf.height)
		{
			_bestSize(width, height);
			_resize(width, height);
			return true;
		}
		
		if(rwidth < (gbuf.width >> 1) - (gbuf.width >> 3) || rheight < (gbuf.height >> 1) - (gbuf.height >> 3))
		{
			_bestSize(width, height);
			if(width < gbuf.width || height < gbuf.height)
			{
				_resize(width, height);
				return true;
			}
		}
		
		return false;
	}
	
	
	/// ditto
	void resize(Size size)
	{
		return resize(size.width, size.height);
	}
	
	
	/// Property: get the graphics buffer.
	Graphics graphicsBuffer() // getter
	{
		return gbuf;
	}
	
	
	/// Property: get the dimensions of the graphics buffer.
	int width() // getter
	{
		return rwidth;
	}
	
	
	/// ditto
	int height() // getter
	{
		return rheight;
	}
	
	
	/// ditto
	Size size() // getter
	{
		return Size(rwidth, rheight);
	}
	
	
	private:
	int rwidth, rheight;
	MemoryGraphics gbuf = null;
	
	
	void _bestSize(inout int width, inout int height)
	{
		width += GRAPHICS_BUFFER_AUTO_GAIN;
		height += GRAPHICS_BUFFER_AUTO_GAIN;
		
		if(width <= GRAPHICS_BUFFER_MINIMUM_SIZE)
			width = GRAPHICS_BUFFER_MINIMUM_SIZE;
		else
			width = _round2power(width);
		
		if(height <= GRAPHICS_BUFFER_MINIMUM_SIZE)
			height = GRAPHICS_BUFFER_MINIMUM_SIZE;
		else
			height = _round2power(height);
	}
	
	
	void _resize(int width, int height)
	{
		gbuf.dispose();
		gbuf = new MemoryGraphics(width, height);
	}
}


/// Mixin for a fixed-size, double buffer Control. ControlStyles ALL_PAINTING_IN_WM_PAINT and USER_PAINT must be set.
template ControlFixedGraphicsBuffer()
{
	protected override void onPaint(PaintEventArgs ea)
	{
		if(!_dbuf)
		{
			_dbuf = new MemoryGraphics(clientSize.width, clientSize.height, ea.graphics);
			auto PaintEventArgs superea = new PaintEventArgs(_dbuf, Rect(0, 0, clientSize.width, clientSize.height));
			onBufferPaint(superea);
			_dbuf.copyTo(ea.graphics);
		}
		else
		{
			_dbuf.copyTo(ea.graphics, ea.clipRectangle.x, ea.clipRectangle.y, ea.clipRectangle.width, ea.clipRectangle.height,
				ea.clipRectangle.x, ea.clipRectangle.y);
		}
	}
	
	
	protected final void onPaintBackground(PaintEventArgs ea)
	{
	}
	
	
	/// Override to draw onto the graphics buffer.
	protected void onBufferPaint(PaintEventArgs ea)
	{
		super.onPaintBackground(ea);
	}
	
	
	/// Updates the double buffer by calling onBufferPaint() and fires a screen-redraw event.
	void updateGraphics(Rect area)
	{
		if(_dbuf)
		{
			auto PaintEventArgs superea = new PaintEventArgs(_dbuf, area);
			onBufferPaint(superea);
		}
		invalidate(area);
	}
	
	
	/// ditto
	void updateGraphics()
	{
		return updateGraphics(Rect(0, 0, clientSize.width, clientSize.height));
	}
	
	
	/// Property: get the graphics buffer. May be null if there is no need for a graphics buffer yet.
	/// invalidate() can be used to fire a screen-redraw event.
	Graphics graphicsBuffer() // getter
	{
		return _dbuf;
	}
	
	
	///
	override void dispose()
	{
		super.dispose();
		if(_dbuf)
			_dbuf.dispose();
	}
	
	
	private:
	MemoryGraphics _dbuf = null;
}


/// Mixin for a variable-size, double buffer Control. ControlStyles ALL_PAINTING_IN_WM_PAINT and USER_PAINT must be set.
template ControlResizableGraphicsBuffer()
{
	protected final void onPaint(PaintEventArgs ea)
	{
		if(!_gbuf.graphics)
		{
			_gbuf.start(clientSize.width, clientSize.height);
			auto PaintEventArgs superea = new PaintEventArgs(_gbuf.graphics, Rect(0, 0, clientSize.width, clientSize.height));
			onBufferPaint(superea);
			_gbuf.copyTo(ea.graphics);
		}
		else
		{
			_gbuf.copyTo(ea.graphics, ea.clipRectangle);
		}
	}
	
	
	protected final void onPaintBackground(PaintEventArgs ea)
	{
	}
	
	
	/// Override to draw onto the graphics buffer.
	protected void onBufferPaint(PaintEventArgs ea)
	{
		super.onPaintBackground(ea);
	}
	
	
	protected override void onResize(EventArgs ea)
	{
		super.onResize(ea);
		
		static if(is(typeof(this) : Form))
		{
			if(FormWindowState.MINIMIZED == windowState)
			{
				//printf("minimize\n");
				return;
			}
		}
		
		if(_gbuf.graphics)
		{
			if(_gbuf.resize(clientSize.width, clientSize.height))
			{
				//printf("resize\n");
			}
			
			if(_gbuf.graphics)
			{
				auto PaintEventArgs superea = new PaintEventArgs(_gbuf.graphics, Rect(0, 0, clientSize.width, clientSize.height));
				onBufferPaint(superea);
			}
		}
		invalidate();
	}
	
	
	/// Updates the double buffer by calling onBufferPaint() and fires a screen-redraw event.
	void updateGraphics(Rect area)
	{
		if(_gbuf.graphics)
		{
			auto PaintEventArgs superea = new PaintEventArgs(_gbuf.graphics, area);
			onBufferPaint(superea);
		}
		invalidate(area);
	}
	
	
	/// ditto
	void updateGraphics()
	{
		return updateGraphics(Rect(0, 0, clientSize.width, clientSize.height));
	}
	
	
	/// Property: get the graphics buffer. May be null if there is no need for a graphics buffer yet.
	/// invalidate() can be used to fire a screen-redraw event.
	Graphics graphicsBuffer() // getter
	{
		return _gbuf.graphicsBuffer;
	}
	
	
	///
	override void dispose()
	{
		super.dispose();
		_gbuf.stop();
	}
	
	
	private:
	ResizableGraphicsBuffer _gbuf;
}

class DoubleBufferedForm: Form
{
	mixin ControlResizableGraphicsBuffer; ///
	
	
	this()
	{
		setStyle(ControlStyles.ALL_PAINTING_IN_WM_PAINT | ControlStyles.USER_PAINT, true);
	}
}


/// Mixes in ControlResizableGraphicsBuffer and sets the appropriate styles.
class DoubleBufferedControl: UserControl
{
	mixin ControlResizableGraphicsBuffer; ///
	
	
	this()
	{
		setStyle(ControlStyles.ALL_PAINTING_IN_WM_PAINT | ControlStyles.USER_PAINT, true);
	}
}


class HexComponent : DoubleBufferedControl {
	long position = 0;
	Stream s;
	Font font;
	Size cell_s;
	Size cell_m;
	Point cursor;
	int ncols = 0x10;
	int nrows = 0x20;
	
	Color black;
	Color white;
	Color blue;
	Color red ;
	Color grey;
	Color grey2;
	
	Pen p_sep;
	Timer t;
	
	bool mustRefresh = true;
	
	bool[0x1000] keysp;
	
	Event!(HexComponent, EventArgs) updatingCoords;
	
	
	void goTo(uint position) {
		cursor.y = 0;
		cursor.x = position % 0x10;
		this.position = position - cursor.x;
		mustRefresh = true;
	}
	
	long cursorPosition() {
		return position + cursor.y * ncols + cursor.x;
	}
	
	void setFont() {
		font = new Font("Courier New", 12, GraphicsUnit.PIXEL);		
		Graphics g = new MemoryGraphics(1, 1);
		cell_s = g.measureText("00", font);
		cell_m = Size(5, 1);
		cell_s += cell_m;
	}
	
	void doTick(Timer t, EventArgs ea) {
		/*if (_scrollPosition != scrollPosition) {
			mustRefresh = true;
			position = (scrollPosition.y * s.size / (scrollSize.height * ncols)) * ncols;
		}*/
		if (mustRefresh) updateGraphics();
	}
		
	this() {
		//Application.addMessageFilter(this);
		
		setFont();

		black = Color(0x00, 0x00, 0x00);
		white = Color(0xFF, 0xFF, 0xFF);
		blue  = Color(0x00, 0x00, 0xFF);
		red   = Color(0xFF, 0x70, 0x70);
		grey  = Color(0x9F, 0x9F, 0x9F);
		grey2 = Color(0xF0, 0xF0, 0xF0);
		
		p_sep = new Pen(grey);
		
		t = new Timer();
		t.interval = 1000 / 50;
		t.tick ~= &doTick;
		t.start();
		
		/*
		ScrollableControl s = new ScrollableControl();
		
		s.autoScroll = false;
		s.width = 40;
		s.height = 300;
		s.vScroll = true;
		s.scrollSize = Size(0, 4000);
		
		s.parent = this;
		*/
		
		
		//vScroll = true;
		//scrollSize = Size(0, 4000);
		//scrollPosition = Point(0, 0);
	}
	
	override protected void onHandleCreated(EventArgs ea) {
		super.onHandleCreated(ea);
		/*
		SCROLLINFO si;
		//if(vScroll)
		si.cbSize = SCROLLINFO.sizeof;
		si.fMask = SIF_RANGE | SIF_PAGE | SIF_POS;
		si.nPos = 0;
		si.nMin = 0;
		si.nMax = 100000;
		si.nPage = 10;
		SetScrollInfo(handle, SB_VERT, &si, true);		
		*/
	}
	
	//Point _scrollPosition;
	
	override void onDisposed(EventArgs ea) {
		//Application.removeMessageFilter(this);
		super.onDisposed(ea);		
	}
	
	Size drawText(Graphics g, char[] str, Font font, Color color, int x, int y, int ax = -1, int ay = -1) {
		Size s = g.measureText(str, font);
		
		Rect tr = Rect(
			x - (s.width  * (ax + 1) >> 1),
			y - (s.height * (ay + 1) >> 1),
			s.width,
			s.height
		);
		
		g.drawText(str, font, color, tr);
		
		return s;
	}
	
	Size drawText(Graphics g, char[] str, Font font, Color color, Point p, int ax = -1, int ay = -1) {
		return drawText(g, str, font, color, p.x, p.y, ax, ay);
	}
	
	void drawRectangle(Graphics g, Color c, Point p, int width, int height) {
		g.fillRectangle(c, p.x, p.y, width, height);
	}
	
	Point XY_t(int column, int y, int x = 0) {
		const int leftStart = 70;
		switch (column) {
			default:
			case 0: return Point(leftStart / 2, y * cell_s.height + 20);
			case 1: return Point(leftStart + 8 + x * cell_s.width, y * cell_s.height + 20);
			case 2: return Point(leftStart + 16 + ncols * cell_s.width + x * (cell_s.width / 2 - 2), y * cell_s.height + 20);
		}		
	}
	
	Point Y(Point p) { return Point(0, p.y); }
	Point X(Point p) { return Point(p.x, 0); }
	
	Point XY_f(int x, int y) {
		Point min = XY_t(1, 0, 0), max = XY_t(1, nrows, ncols);
		
		if (x < min.x) x = min.x;
		if (y < min.y) y = min.y;
		
		if (x < min.x || x >= max.x || y < min.y || y >= max.y) throw(new Exception("Invalid"));
		
		return Point(
			(x - min.x) * ncols / (max.x - min.x),
			(y - min.y) * nrows / (max.y - min.y)
		);
	}
	
	protected void onMouseDown(MouseEventArgs mea) {		
		if (!parent.focused) return;
		try {
			Point p = XY_f(mea.x, mea.y);
			setCursor(p.x, p.y);
		} catch {
		}
	}
	
	protected void onMouseMove(MouseEventArgs mea) {
		if (!mea.button) return;
		onMouseDown(mea);
	}
	
	void drawBackground(Graphics g) {
		// pintamos el fondo
		g.fillRectangle(white, 0, 0, width, height);
	}

	override protected void onBufferPaint(PaintEventArgs pea) {			
		//if (!mustRefresh) return;
		mustRefresh = false;
		updatingCoords(this, EventArgs.empty);

		Graphics g = pea.graphics;
		
		drawBackground(g);
		
		int[] guides = [ XY_t(1, 0, 0).x - 6, XY_t(1, 0, ncols).x ];
		
		Point guide_p = XY_t(1, cursor.y, cursor.x) - Size(cell_m.width / 2, 0);
		
		drawRectangle(g, grey2, Y(guide_p), width, cell_s.height);
		drawRectangle(g, grey2, X(guide_p), cell_s.width, height);
		
		drawRectangle(g, red, guide_p, cell_s.width, cell_s.height);		
		
		drawRectangle(g, red, XY_t(2, cursor.y, cursor.x), cell_s.width / 2, cell_s.height);		
		
		foreach (guide; guides) g.drawLine(p_sep, guide, 0, guide, height);		
		g.drawLine(p_sep, 0, 17, width, 17);
		
		drawText(g, "Offset", font, blue, X(XY_t(0, 0)) + Size(0, 1), 0, -1);

		for (int x = 0; x < ncols; x++) {			
			drawText(g, std.string.format("%02X", x), font, blue, X(XY_t(1, -1, x)) + Size(0, 1));
		}
		
		if (!s) return;
		
		position &= ~0x0F;

		s.position = position;
		
		for (int y = 0; y < 100; y++) {			
			Point p = XY_t(0, y); if (p.y + cell_s.height >= height) { nrows = y; break; }
		
			if (!s.eof) {
				drawText(g, std.string.format("%08X", s.position), font, blue, p, 0, -1);
				
				
				ubyte[] row_d = new ubyte[ncols];
				int max; try { max = s.read(row_d); } catch { }
				
				for (int x = 0; x < max; x++) {
					char c = cast(char)row_d[x];
					char[] cc = (c < 0x20 || c == 0x7f) ? "." : [c];
					drawText(g, std.string.format("%02X", row_d[x]), font, black, XY_t(1, y, x));				
					drawText(g, fromAnsi(cc.ptr, 1), font, black, XY_t(2, y, x));
				}
			}
		}
	}
		
	void moveCursor(int x, int y) {
		cursor.x += x;
		cursor.y += y;
		
		while (cursor.x < 0) {
			cursor.x = ncols + cursor.x;
			cursor.y--;
			if (cursor.y < 0 && position <= 0) cursor.x = 0;
		}

		while (cursor.x >= ncols) {
			cursor.x = cursor.x - ncols;
			cursor.y++;
		}
		
		while (cursor.y < 0) {
			cursor.y++;
			if (position >= ncols) position -= ncols;
		}
		
		while (cursor.y >= nrows) {
			if (cursor.y <= 0) break;			
			cursor.y--;
			
			if (position <= s.size - ncols) {
				position += ncols;								
			} else {
				nrows--;
			}
		}
		
		mustRefresh = true;
	}

	void setCursor(int x, int y) {
		cursor.x = x;
		cursor.y = y;
		mustRefresh = true;
	}
	
	void setCursorX(int x) {
		cursor.x = x;
		mustRefresh = true;
	}
		
	void keyChange(Keys key, bool pressed) {
		keysp[key] = pressed;
		
		if (keysp[Keys.UP   ]) moveCursor( 0, -1);
		if (keysp[Keys.DOWN ]) moveCursor( 0, +1);
		if (keysp[Keys.LEFT ]) moveCursor(-1,  0);
		if (keysp[Keys.RIGHT]) moveCursor(+1,  0);
		
		if (keysp[Keys.HOME ]) setCursorX(0);
		if (keysp[Keys.END  ]) setCursorX(ncols - 1);

		if (keysp[Keys.PAGE_UP]) moveCursor(0, -((nrows >> 1) + 1));
		if (keysp[Keys.PAGE_DOWN]) moveCursor(0, +((nrows >> 1) + 1));
	}
		
	void onKeyDown(KeyEventArgs kea) {
		keyChange(kea.keyCode, true);
	}

	void onKeyUp(KeyEventArgs kea) {
		keyChange(kea.keyCode, false);
	}
}
