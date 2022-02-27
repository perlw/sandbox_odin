package xcb

Keycode   :: distinct u8
Timestamp :: distinct u32
Atom      :: distinct u32
Drawable  :: distinct u32
Window    :: distinct u32
Colormap  :: distinct u32
Visualid  :: distinct u32
Gcontext  :: distinct u32
Pixmap    :: distinct u32

Connection :: struct {}

Setup :: struct {
	status:                      u8,
	pad0:                        u8,
	protocol_major_version:      u16,
	protocol_minor_version:      u16,
	length:                      u16,
	release_number:              u32,
	resource_id_base:            u32,
	resource_id_mask:            u32,
	motion_buffer_size:          u32,
	vendor_len:                  u16,
	maximum_request_length:      u16,
	roots_len:                   u8,
	pixmap_formats_len:          u8,
	image_byte_order:            u8,
	bitmap_format_bit_order:     u8,
	bitmap_format_scanline_unit: u8,
	bitmap_format_scanline_pad:  u8,
	min_keycode:                 Keycode,
	max_keycode:                 Keycode,
	pad1:                        [4]u8,
}

Screen :: struct {
	root:                  Window,
	default_colormap:      Colormap,
	white_pixel:           u32,
	black_pixel:           u32,
	current_input_masks:   u32,
	width_in_pixels:       u16,
	height_in_pixels:      u16,
	width_in_millimeters:  u16,
	height_in_millimeters: u16,
	min_installed_maps:    u16,
	max_installed_maps:    u16,
	root_visual:           Visualid,
	backing_stores:        u8,
	save_unders:           u8,
	root_depth:            u8,
	allowed_depths_len:    u8,
}

ScreenIterator :: struct {
	data:  ^Screen,
	rem:   i32,
	index: i32,
}

WindowClass :: enum u16 {
	Copy_From_Parent = 0,
	Input_Output     = 1,
	Input_Only       = 2,
}

Cw :: enum u32 {
	Back_Pixmap       = 1,
	Back_Pixel        = 2,
	Border_Pixmap     = 4,
	Border_Pixel      = 8,
	Bit_Gravity       = 16,
	Win_Gravity       = 32,
	Backing_Store     = 64,
	Backing_Planes    = 128,
	Backing_Pixel     = 256,
	Override_Redirect = 512,
	Save_Under        = 1024,
	Event_Mask        = 2048,
	Dont_Propagate    = 4096,
	Colormap          = 8192,
	Cursor            = 16384,
}

EventMask :: enum u32 {
	No_Event              = 0,
	Key_Press             = 1,
	Key_Release           = 2,
	Button_Press          = 4,
	Button_Release        = 8,
	Enter_Window          = 16,
	Leave_Window          = 32,
	Pointer_Motion        = 64,
	Pointer_Motion_Hint   = 128,
	Button_1_Motion       = 256,
	Button_2_Motion       = 512,
	Button_3_Motion       = 1024,
	Button_4_Motion       = 2048,
	Button_5_Motion       = 4096,
	Button_Motion         = 8192,
	Keymap_State          = 16384,
	Exposure              = 32768,
	Visibility_Change     = 65536,
	Structure_Notify      = 131072,
	Resize_Redirect       = 262144,
	Substructure_Notify   = 524288,
	Substructure_Redirect = 1048576,
	Focus_Change          = 2097152,
	Property_Change       = 4194304,
	Color_Map_Change      = 8388608,
	Owner_Grab_Button     = 16777216,
}

KEY_PRESS      : u8 : 2
KEY_RELEASE    : u8 : 3
EXPOSE         : u8 : 12
CLIENT_MESSAGE : u8 : 33

KeyPressEvent :: struct {
	response_type: u8,
	detail:        Keycode,
	sequence:      u16,
	time:          Timestamp,
	root:          Window,
	event:         Window,
	child:         Window,
	root_x:        i16,
	root_y:        i16,
	event_x:       i16,
	event_y:       i16,
	state:         u16,
	same_screen:   u8,
	pad0:          u8,
}
KeyReleaseEvent :: distinct KeyPressEvent

ClientMessageData :: struct #raw_union {
	data8:  [20]u8,
	data16: [10]u16,
	data32: [5]u32,
}

ClientMessageEvent :: struct {
	response_type: u8,
	format:        u8,
	sequence:      u16,
	window:        Window,
	type:          AtomEnum,
	data:          ClientMessageData,
}

PropMode :: enum u8 {
	Replace = 0,
	Prepend = 1,
	Append  = 2,
}

AtomEnum :: enum u32 {
	None                = 0,
	Any                 = 0,
	Primary             = 1,
	Secondary           = 2,
	Arc                 = 3,
	Atom                = 4,
	Bitmap              = 5,
	Cardinal            = 6,
	Colormap            = 7,
	Cursor              = 8,
	Cut_Buffer0         = 9,
	Cut_Buffer1         = 10,
	Cut_Buffer2         = 11,
	Cut_Buffer3         = 12,
	Cut_Buffer4         = 13,
	Cut_Buffer5         = 14,
	Cut_Buffer6         = 15,
	Cut_Buffer7         = 16,
	Drawable            = 17,
	Font                = 18,
	Integer             = 19,
	Pixmap              = 20,
	Point               = 21,
	Rectangle           = 22,
	Resource_Manager    = 23,
	Rgb_Color_Map       = 24,
	Rgb_Best_Map        = 25,
	Rgb_Blue_Map        = 26,
	Rgb_Default_Map     = 27,
	Rgb_Gray_Map        = 28,
	Rgb_Green_Map       = 29,
	Rgb_Red_Map         = 30,
	String              = 31,
	Visualid            = 32,
	Window              = 33,
	Wm_Command          = 34,
	Wm_Hints            = 35,
	Wm_Client_Machine   = 36,
	Wm_Icon_Name        = 37,
	Wm_Icon_Size        = 38,
	Wm_Name             = 39,
	Wm_Normal_Hints     = 40,
	Wm_Size_Hints       = 41,
	Wm_Zoom_Hints       = 42,
	Min_Space           = 43,
	Norm_Space          = 44,
	Max_Space           = 45,
	End_Space           = 46,
	Superscript_X       = 47,
	Superscript_Y       = 48,
	Subscript_X         = 49,
	Subscript_Y         = 50,
	Underline_Position  = 51,
	Underline_Thickness = 52,
	Strikeout_Ascent    = 53,
	Strikeout_Descent   = 54,
	Italic_Angle        = 55,
	X_Height            = 56,
	Quad_Width          = 57,
	Weight              = 58,
	Point_Size          = 59,
	Resolution          = 60,
	Copyright           = 61,
	Notice              = 62,
	Font_Name           = 63,
	Family_Name         = 64,
	Full_Name           = 65,
	Cap_Height          = 66,
	Wm_Class            = 67,
	Wm_Transient_For    = 68,
}

BaseReply :: struct {
	response_type: u8,
	pad0:          u8,
	sequence:      u16,
	length:        u32,
}

InternAtomReply :: struct {
	using base: BaseReply,
	atom:       Atom,
}

Extension :: struct {
	name:      cstring,
	global_id: i32,
}

QueryExtensionReply :: struct {
	using base: BaseReply,
	present:       u8,
	major_opcode:  u8,
	first_event:   u8,
	first_error:   u8,
}

ImageFormat :: enum u8 {
	xy_bitmap = 0,
	xy_pixmap = 1,
	z_pixmap  = 2,
}

foreign import xproto "system:xcb"
@(default_calling_convention = "std")
@(link_prefix="xcb_")
foreign xproto {
	setup_roots_iterator :: proc(setup: ^Setup) -> ScreenIterator ---

	create_window :: proc(
		connection: ^Connection,
		depth: u8,
		window_id: Window,
		parent: Window,
		x: i16,
		y: i16,
		width: u16,
		height: u16,
		border_width: u16,
		class: WindowClass,
		visual: Visualid,
		value_mask: u32,
		value_list: rawptr,
	) -> VoidCookie ---
	destroy_window :: proc(connection: ^Connection, window: Window) -> VoidCookie ---
	map_window :: proc(connection: ^Connection, window: Window) -> VoidCookie ---

	change_property :: proc(
		connection: ^Connection,
		mode: PropMode,
		window: Window,
		property: Atom,
		type: AtomEnum,
		format: u8,
		data_len: u32,
		data: rawptr,
	) -> VoidCookie ---
	create_gc :: proc(
		connection: ^Connection,
		ctx_id: Gcontext,
		drawable: Drawable,
		value_mask: u32,
		value_list: rawptr,
	) -> VoidCookie ---

	intern_atom :: proc(
		connection: ^Connection,
		only_if_exists: u8,
		name_len: u16,
		name: cstring,
	) -> InternAtomCookie ---
	intern_atom_reply :: proc(
		connection: ^Connection,
		cookie: InternAtomCookie,
		err: ^^GenericError,
	) -> ^InternAtomReply ---

	free_pixmap :: proc(connection: ^Connection, pixmap: Pixmap) -> VoidCookie ---
}
