import std.c.windows.windows;
import std.stdio;

void bind(HANDLE dll, void** ptr, char* name) { assert((*ptr = GetProcAddress(dll, name)) !is null, "Can't bind function"); }
char[] bind(char[] t) { return "bind(dll, cast(void**)&" ~ t ~ ", \"" ~ t ~ "\");"; }
char[] bind_lib(char[] t) { return "assert((dll = LoadLibraryA(\"" ~ t ~ "\")) != null, \"Can't load library\");"; }

static this() {
	static HANDLE dll;

	mixin(
		bind_lib("libusb0.dll") ~
	
		bind("usb_open") ~
		bind("usb_close") ~
		bind("usb_get_string") ~
		bind("usb_get_string_simple") ~

		// descriptors.c
		bind("usb_get_descriptor_by_endpoint") ~
		bind("usb_get_descriptor") ~

		// <arch>.c
		bind("usb_bulk_write") ~
		bind("usb_bulk_read") ~
		bind("usb_interrupt_write") ~
		bind("usb_interrupt_read") ~
		bind("usb_control_msg") ~
		bind("usb_set_configuration") ~
		bind("usb_claim_interface") ~
		bind("usb_release_interface") ~
		bind("usb_set_altinterface") ~
		bind("usb_resetep") ~
		bind("usb_clear_halt") ~
		bind("usb_reset") ~

		bind("usb_strerror") ~

		bind("usb_init") ~
		bind("usb_set_debug") ~
		bind("usb_find_busses") ~
		bind("usb_find_devices") ~
		bind("usb_device") ~
		bind("usb_get_busses") ~

		// Windows specific functions
		bind("usb_install_service_np") ~
		bind("usb_install_service_np_rundll") ~

		bind("usb_uninstall_service_np") ~
		bind("usb_uninstall_service_np_rundll") ~

		bind("usb_install_driver_np") ~
		bind("usb_install_driver_np_rundll") ~

		bind("usb_touch_inf_file_np") ~
		bind("usb_touch_inf_file_np_rundll") ~

		bind("usb_get_version") ~

		bind("usb_isochronous_setup_async") ~
		bind("usb_bulk_setup_async") ~
		bind("usb_interrupt_setup_async") ~

		bind("usb_submit_async") ~
		bind("usb_reap_async") ~
		bind("usb_reap_async_nocancel") ~
		bind("usb_cancel_async") ~
		bind("usb_free_async") ~
	"");
}

extern (Windows) {
	static const int LIBUSB_PATH_MAX = 512;

	// Device and/or Interface Class codes
	enum {
		USB_CLASS_PER_INTERFACE = 0, // for DeviceClass
		USB_CLASS_AUDIO         = 1,
		USB_CLASS_COMM          = 2,
		USB_CLASS_HID           = 3,
		USB_CLASS_PRINTER       = 7,
		USB_CLASS_MASS_STORAGE  = 8,
		USB_CLASS_HUB           = 9,
		USB_CLASS_DATA          = 10,
		USB_CLASS_VENDOR_SPEC   = 0xff,
	}

	// Descriptor types
	enum {
		USB_DT_DEVICE    = 0x01,
		USB_DT_CONFIG    = 0x02,
		USB_DT_STRING    = 0x03,
		USB_DT_INTERFACE = 0x04,
		USB_DT_ENDPOINT  = 0x05,

		USB_DT_HID       = 0x21,
		USB_DT_REPORT    = 0x22,
		USB_DT_PHYSICAL  = 0x23,
		USB_DT_HUB       = 0x29,
	}

	// Descriptor sizes per descriptor type
	enum {
		USB_DT_DEVICE_SIZE = 18,
		USB_DT_CONFIG_SIZE = 9,
		USB_DT_INTERFACE_SIZE = 9,
		USB_DT_ENDPOINT_SIZE = 7,
		USB_DT_ENDPOINT_AUDIO_SIZE = 9,	/* Audio extension */
		USB_DT_HUB_NONVAR_SIZE = 7,
	}

	// All standard descriptors have these 2 fields in common
	align(1) struct usb_descriptor_header {
		ubyte  bLength;
		ubyte  bDescriptorType;
	}

	// String descriptor
	align(1) struct usb_string_descriptor {
		ubyte  bLength;
		ubyte  bDescriptorType;
		ushort wData[1];
	}

	// HID descriptor
	align(1) struct usb_hid_descriptor {
		ubyte  bLength;
		ubyte  bDescriptorType;
		ushort bcdHID;
		ubyte  bCountryCode;
		ubyte  bNumDescriptors;
	}

	// Endpoint descriptor
	static const int USB_MAXENDPOINTS = 32;

	align(1) struct usb_endpoint_descriptor {
		ubyte  bLength;
		ubyte  bDescriptorType;
		ubyte  bEndpointAddress;
		ubyte  bmAttributes;
		ushort wMaxPacketSize;
		ubyte  bInterval;
		ubyte  bRefresh;
		ubyte  bSynchAddress;

		ubyte *extra;	// Extra descriptors
		int extralen;
	}

	enum {
		USB_ENDPOINT_ADDRESS_MASK     = 0x0f, // in bEndpointAddress
		USB_ENDPOINT_DIR_MASK         = 0x80,

		USB_ENDPOINT_TYPE_MASK        = 0x03, // in bmAttributes
		USB_ENDPOINT_TYPE_CONTROL     = 0,
		USB_ENDPOINT_TYPE_ISOCHRONOUS = 1,
		USB_ENDPOINT_TYPE_BULK        = 2,
		USB_ENDPOINT_TYPE_INTERRUPT   = 3,
	}

	// Interface descriptor
	static const int USB_MAXINTERFACES = 32;

	align(1) struct usb_interface_descriptor {
		ubyte  bLength;
		ubyte  bDescriptorType;
		ubyte  bInterfaceNumber;
		ubyte  bAlternateSetting;
		ubyte  bNumEndpoints;
		ubyte  bInterfaceClass;
		ubyte  bInterfaceSubClass;
		ubyte  bInterfaceProtocol;
		ubyte  iInterface;

		usb_endpoint_descriptor *endpoint;

		ubyte *extra; // Extra descriptors
		int extralen;
	}

	static const int USB_MAXALTSETTING = 128; // Hard limit

	align(1) struct usb_interface {
		usb_interface_descriptor *altsetting;
		int num_altsetting;
	}

	// Configuration descriptor information

	static const int USB_MAXCONFIG = 8;

	align(1) struct usb_config_descriptor {
	  ubyte  bLength;
	  ubyte  bDescriptorType;
	  ushort wTotalLength;
	  ubyte  bNumInterfaces;
	  ubyte  bConfigurationValue;
	  ubyte  iConfiguration;
	  ubyte  bmAttributes;
	  ubyte  MaxPower;

	  usb_interface* _interface;

	  ubyte *extra;	// Extra descriptors
	  int extralen;
	}

	// Device descriptor
	align(1) struct usb_device_descriptor {
	  ubyte  bLength;
	  ubyte  bDescriptorType;
	  ushort bcdUSB;
	  ubyte  bDeviceClass;
	  ubyte  bDeviceSubClass;
	  ubyte  bDeviceProtocol;
	  ubyte  bMaxPacketSize0;
	  ushort idVendor;
	  ushort idProduct;
	  ushort bcdDevice;
	  ubyte  iManufacturer;
	  ubyte  iProduct;
	  ubyte  iSerialNumber;
	  ubyte  bNumConfigurations;
	}

	align(1) struct usb_ctrl_setup {
		ubyte  bRequestType;
		ubyte  bRequest;
		ushort wValue;
		ushort wIndex;
		ushort wLength;
	}

	// Standard requests
	enum {
		USB_REQ_GET_STATUS          = 0x00,
		USB_REQ_CLEAR_FEATURE       = 0x01,
		__USB_REQ_RESERVED_02       = 0x02,
		USB_REQ_SET_FEATURE         = 0x03,
		__USB_REQ_RESERVED_04       = 0x04,
		USB_REQ_SET_ADDRESS         = 0x05,
		USB_REQ_GET_DESCRIPTOR      = 0x06,
		USB_REQ_SET_DESCRIPTOR      = 0x07,
		USB_REQ_GET_CONFIGURATION   = 0x08,
		USB_REQ_SET_CONFIGURATION   = 0x09,
		USB_REQ_GET_INTERFACE       = 0x0A,
		USB_REQ_SET_INTERFACE       = 0x0B,
		USB_REQ_SYNCH_FRAME         = 0x0C,
	}

	enum {
		USB_TYPE_STANDARD = (0x00 << 5),
		USB_TYPE_CLASS    = (0x01 << 5),
		USB_TYPE_VENDOR   = (0x02 << 5),
		USB_TYPE_RESERVED = (0x03 << 5),
	}

	enum {
		USB_RECIP_DEVICE    = 0x00,
		USB_RECIP_INTERFACE = 0x01,
		USB_RECIP_ENDPOINT  = 0x02,
		USB_RECIP_OTHER     = 0x03,
	}

	// Various libusb API related stuff
	enum {
		USB_ENDPOINT_IN  = 0x80,
		USB_ENDPOINT_OUT = 0x00,
	}

	// Error codes
	enum {
		USB_ERROR_BEGIN = 500000,
	}

	align(1) struct usb_device_s {
		usb_device_s* next, prev;

		char filename[LIBUSB_PATH_MAX];

		usb_bus* bus;

		usb_device_descriptor  descriptor;
		usb_config_descriptor* config;

		void* dev;		/* Darwin support */

		ubyte devnum;

		ubyte num_children;
		usb_device_s** children;
		
		char[] filename_d() { return std.string.toString(cast(char *)filename); }
	}

	align(1) struct usb_bus {
		usb_bus* next, prev;

		char dirname[LIBUSB_PATH_MAX];

		usb_device_s* devices;
		uint location;

		usb_device_s* root_dev;
		
		char[] dirname_d() { return std.string.toString(cast(char *)dirname); }		
	};

	// Version information, Windows specific
	align(1) struct usb_version {
		struct DLL {
			int major;
			int minor;
			int micro;
			int nano;
		} DLL dll;
		
		struct DRIVER {
			int major;
			int minor;
			int micro;
			int nano;
		} DRIVER driver;
		
		char[] toString() { return std.string.format("DLL(%d.%d.%d.%d) DRIVER(%d.%d.%d.%d)", dll.major, dll.minor, dll.micro, dll.nano, driver.major, driver.minor, driver.micro, driver.nano); }
		
		static char[] get() { return (*usb_get_version()).toString; }
	}

	struct usb_dev_handle;

	// Variables
	usb_bus* usb_busses() { return usb_get_busses(); }


	// Function prototypes

	// usb.c
	usb_dev_handle* function(usb_device_s *dev) usb_open;
	int function(usb_dev_handle* dev) usb_close;
	int function(usb_dev_handle* dev, int index, int langid, char* buf, size_t buflen) usb_get_string;
	int function(usb_dev_handle* dev, int index, char *buf, size_t buflen) usb_get_string_simple;

	// descriptors.c
	int function(usb_dev_handle* udev, int ep, ubyte type, ubyte index, void* buf, int size) usb_get_descriptor_by_endpoint;
	int function(usb_dev_handle* udev, ubyte type, ubyte index, void* buf, int size) usb_get_descriptor;

	// <arch>.c
	int function(usb_dev_handle* dev, int ep, void* bytes, int size, int timeout) usb_bulk_write;
	int function(usb_dev_handle* dev, int ep, void* bytes, int size, int timeout) usb_bulk_read;
	int function(usb_dev_handle* dev, int ep, void* bytes, int size, int timeout) usb_interrupt_write;
	int function(usb_dev_handle* dev, int ep, void* bytes, int size, int timeout) usb_interrupt_read;
	int function(usb_dev_handle* dev, int requesttype, int request, int value, int index, char* bytes, int size, int timeout) usb_control_msg;
	int function(usb_dev_handle* dev, int configuration) usb_set_configuration;
	int function(usb_dev_handle* dev, int _interface) usb_claim_interface;
	int function(usb_dev_handle* dev, int _interface) usb_release_interface;
	int function(usb_dev_handle* dev, int alternate) usb_set_altinterface;
	int function(usb_dev_handle* dev, uint ep) usb_resetep;
	int function(usb_dev_handle* dev, uint ep) usb_clear_halt;
	int function(usb_dev_handle* dev) usb_reset;

	char* function() usb_strerror;

	void function() usb_init;
	void function(int level) usb_set_debug;
	int  function() usb_find_busses;
	int  function() usb_find_devices;
	usb_device_s* function(usb_dev_handle *dev) usb_device;
	usb_bus* function() usb_get_busses;

	// Windows specific functions

	int function() usb_install_service_np;
	void function(HWND wnd, HINSTANCE instance, LPSTR cmd_line, int cmd_show) usb_install_service_np_rundll;

	int function() usb_uninstall_service_np;
	void function(HWND wnd, HINSTANCE instance, LPSTR cmd_line, int cmd_show) usb_uninstall_service_np_rundll;

	int function(char* inf_file) usb_install_driver_np;
	void function(HWND wnd, HINSTANCE instance, LPSTR cmd_line, int cmd_show) usb_install_driver_np_rundll;

	int function(char* inf_file) usb_touch_inf_file_np;
	void function(HWND wnd, HINSTANCE instance, LPSTR cmd_line, int cmd_show) usb_touch_inf_file_np_rundll;

	usb_version* function() usb_get_version;

	int function(usb_dev_handle *dev, void **context, ubyte ep, int pktsize) usb_isochronous_setup_async;
	int function(usb_dev_handle *dev, void **context, ubyte ep) usb_bulk_setup_async;
	int function(usb_dev_handle *dev, void **context, ubyte ep) usb_interrupt_setup_async;

	int function(void*  context, char* bytes, int size) usb_submit_async;
	int function(void*  context, int timeout) usb_reap_async;
	int function(void*  context, int timeout) usb_reap_async_nocancel;
	int function(void*  context) usb_cancel_async;
	int function(void** context) usb_free_async;
}

ubyte[] usb_bulk_read_d(usb_dev_handle* dev, int ep, int length, int timeout = 1000) {
	ubyte[] data = new ubyte[length];
	int len = usb_bulk_read(dev, ep, cast(char *)data.ptr, data.length, timeout);
	//assert(len >= 0, "usb_bulk_read returned a negative value");
	if (len < 0) return [];
	return data[0..len];
}

int usb_bulk_write_d(usb_dev_handle* dev, int ep, ubyte[] data, int timeout = 1000) {
	//writefln(data.length);
	return usb_bulk_write(dev, ep, cast(char *)data.ptr, data.length, timeout);
}
