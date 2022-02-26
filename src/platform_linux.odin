//+build linux
package main

import "core:fmt"
import "core:c"
import "core:c/libc"

XcbConnection :: struct {}

XcbKeycode :: distinct u8
XcbTimestamp :: distinct u32
XcbAtom :: distinct u32

XcbSetup :: struct {
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
	min_keycode:                 XcbKeycode,
	max_keycode:                 XcbKeycode,
	pad1:                        [4]u8,
}

XcbDrawable :: distinct u32
XcbWindow :: distinct u32
XcbColorMap :: distinct u32
XcbVisualId :: distinct u32
XcbGContext :: distinct u32
XcbShmSeg :: distinct u32
XcbPixmap :: distinct u32

XcbVoidCookie :: struct {
	sequence: u32,
}

XcbInternAtomCookie :: struct {
	sequence: u32,
}

XcbGenericError :: struct {
	response_type: u8,
	error_code:    u8,
	sequence:      u16,
	resource_id:   u32,
	minor_code:    u16,
	major_code:    u16,
	pad0:          u8,
	pad:           [5]u32,
	full_sequence: u32,
}

XcbScreen :: struct {
	root:                  XcbWindow,
	default_colormap:      XcbColorMap,
	white_pixel:           u32,
	black_pixel:           u32,
	current_input_masks:   u32,
	width_in_pixels:       u16,
	height_in_pixels:      u16,
	width_in_millimeters:  u16,
	height_in_millimeters: u16,
	min_installed_maps:    u16,
	max_installed_maps:    u16,
	root_visual:           XcbVisualId,
	backing_stores:        u8,
	save_unders:           u8,
	root_depth:            u8,
	allowed_depths_len:    u8,
}

XcbScreenIterator :: struct {
	data:  ^XcbScreen,
	rem:   i32,
	index: i32,
}

XcbGenericEvent :: struct {
	response_type: u8,
	pad0:          u8,
	sequence:      u16,
	pad:           [7]u32,
	full_sequence: u32,
}

XCB_COPY_FROM_PARENT: u8 : 0

XcbWindowClass :: enum u16 {
	Copy_From_Parent = 0,
	Input_Output     = 1,
	Input_Only       = 2,
}

XcbCW :: enum u32 {
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

XcbEventMask :: enum u32 {
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

XCB_EXPOSE: u8 : 12

XCB_KEY_PRESS: u8 : 2
XCB_KEY_RELEASE: u8 : 3

XcbKeyPressEvent :: struct {
	response_type: u8,
	detail:        XcbKeycode,
	sequence:      u16,
	time:          XcbTimestamp,
	root:          XcbWindow,
	event:         XcbWindow,
	child:         XcbWindow,
	root_x:        i16,
	root_y:        i16,
	event_x:       i16,
	event_y:       i16,
	state:         u16,
	same_screen:   u8,
	pad0:          u8,
}
XcbKeyReleaseEvent :: distinct XcbKeyPressEvent

XCB_CLIENT_MESSAGE: u8 : 33

XcbClientMessageData :: struct #raw_union {
	data8:  [20]u8,
	data16: [10]u16,
	data32: [5]u32,
}

XcbClientMessageEvent :: struct {
	response_type: u8,
	format:        u8,
	sequence:      u16,
	window:        XcbWindow,
	type:          XcbAtomEnum,
	data:          XcbClientMessageData,
}

XcbPropMode :: enum u8 {
	Replace = 0,
	Prepend = 1,
	Append  = 2,
}

XcbAtomEnum :: enum u32 {
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

XcbBaseReply :: struct {
	response_type: u8,
	pad0:          u8,
	sequence:      u16,
	length:        u32,
}

XcbInternAtomReply :: struct {
	using base: XcbBaseReply,
	atom:       XcbAtom,
}

XcbExtension :: struct {
	name:      cstring,
	global_id: i32,
}

XcbQueryExtensionReply :: struct {
	using base: XcbBaseReply,
	present:       u8,
	major_opcode:  u8,
	first_event:   u8,
	first_error:   u8,
}

XcbImageFormat :: enum u8 {
	xy_bitmap = 0,
	xy_pixmap = 1,
	z_pixmap  = 2,
}

foreign import xcb "system:xcb"
@(default_calling_convention = "std")
foreign xcb {
	xcb_connect :: proc(display_name: cstring, screen_p: ^c.int) -> ^XcbConnection ---
	xcb_disconnect :: proc(connection: ^XcbConnection) ---

	xcb_get_setup :: proc(connection: ^XcbConnection) -> ^XcbSetup ---
	xcb_setup_roots_iterator :: proc(setup: ^XcbSetup) -> XcbScreenIterator ---

	xcb_generate_id :: proc(connection: ^XcbConnection) -> u32 ---
	xcb_flush :: proc(conncetion: ^XcbConnection) -> u32 ---
	xcb_poll_for_event :: proc(connection: ^XcbConnection) -> ^XcbGenericEvent ---

	xcb_create_window :: proc(
		connection: ^XcbConnection,
		depth: u8,
		window_id: XcbWindow,
		parent: XcbWindow,
		x: i16,
		y: i16,
		width: u16,
		height: u16,
		border_width: u16,
		class: XcbWindowClass,
		visual: XcbVisualId,
		value_mask: u32,
		value_list: rawptr,
	) -> XcbVoidCookie ---
	xcb_destroy_window :: proc(connection: ^XcbConnection, window: XcbWindow) -> XcbVoidCookie ---
	xcb_map_window :: proc(connection: ^XcbConnection, window: XcbWindow) -> XcbVoidCookie ---
	xcb_change_property :: proc(
		connection: ^XcbConnection,
		mode: XcbPropMode,
		window: XcbWindow,
		property: XcbAtom,
		type: XcbAtomEnum,
		format: u8,
		data_len: u32,
		data: rawptr,
	) -> XcbVoidCookie ---
	xcb_create_gc :: proc(
		connection: ^XcbConnection,
		ctx_id: XcbGContext,
		drawable: XcbDrawable,
		value_mask: u32,
		value_list: rawptr,
	) -> XcbVoidCookie ---

	xcb_intern_atom :: proc(
		connection: ^XcbConnection,
		only_if_exists: u8,
		name_len: u16,
		name: cstring,
	) -> XcbInternAtomCookie ---
	xcb_intern_atom_reply :: proc(
		connection: ^XcbConnection,
		cookie: XcbInternAtomCookie,
		err: ^^XcbGenericError,
	) -> ^XcbInternAtomReply ---

	xcb_free_pixmap :: proc(connection: ^XcbConnection, pixmap: XcbPixmap) -> XcbVoidCookie ---

	xcb_get_extension_data :: proc(connection: ^XcbConnection, ext: ^XcbExtension) -> ^XcbQueryExtensionReply ---
}

XcbKeySymbols :: struct {}
XcbKeySym :: u32

foreign import xcb_keysyms "system:xcb-keysyms"
@(default_calling_convention = "std")
foreign xcb_keysyms {
	xcb_key_symbols_alloc :: proc(connection: ^XcbConnection) -> ^XcbKeySymbols ---
	xcb_key_symbols_free :: proc(symbols: ^XcbKeySymbols) ---
	xcb_key_press_lookup_keysym :: proc(
		symbols: ^XcbKeySymbols,
		event: ^XcbKeyPressEvent,
		col: i32,
	) -> XcbKeySym ---
	xcb_key_release_lookup_keysym :: proc(
		symbols: ^XcbKeySymbols,
		event: ^XcbKeyReleaseEvent,
		col: i32,
	) -> XcbKeySym ---
}

XcbErrorsContext :: struct {}

foreign import xcb_errors "system:xcb-errors"
@(default_calling_convention = "std")
foreign xcb_errors {
	xcb_errors_context_new :: proc(connection: ^XcbConnection, ctx: ^^XcbErrorsContext) -> u32 ---
	xcb_errors_get_name_for_major_code :: proc(ctx: ^XcbErrorsContext, major_code: u8) -> cstring ---
	xcb_errors_get_name_for_minor_code :: proc(
		ctx: ^XcbErrorsContext,
		major_code: u8,
		minor_code: u16,
	) -> cstring ---
	xcb_errors_get_name_for_error :: proc(
		ctx: ^XcbErrorsContext,
		error_code: u8,
		extension: ^cstring,
	) -> cstring ---
	xcb_errors_context_free :: proc(ctx: ^XcbErrorsContext) ---
}

XcbShmQueryVersionCookie :: struct {
	sequence: u32,
}

XcbShmQueryVersionReply :: struct {
	response_type:  u8,
	shared_pixmaps: u8,
	sequence:       u16,
	length:         u32,
	major_version:  u16,
	minor_version:  u16,
	uid:            u16,
	gid:            u16,
	pixmap_format:  u8,
	pad0:           [15]u8,
}

xcb_shm_id := XcbExtension {
	name      = "MIT-SHM",
	global_id = 0,
}

XCB_SHM_COMPLETION :: 0

foreign import xcb_shm "system:xcb-shm"
@(default_calling_convention = "std")
foreign xcb_shm {
	xcb_shm_query_version :: proc(connection: ^XcbConnection) -> XcbShmQueryVersionCookie ---
	xcb_shm_query_version_reply :: proc(
		connection: ^XcbConnection,
		cookie: XcbShmQueryVersionCookie,
		err: ^^XcbGenericError,
	) -> ^XcbShmQueryVersionReply ---
	xcb_shm_attach :: proc(
		connection: ^XcbConnection,
		shm_seg: XcbShmSeg,
		shm_id: u32,
		read_only: u8,
	) -> XcbVoidCookie ---
	xcb_shm_detach :: proc(connection: ^XcbConnection, shm_seg: XcbShmSeg) -> XcbVoidCookie ---
	xcb_shm_create_pixmap :: proc(
		connection: ^XcbConnection,
		pixmap: XcbPixmap,
		drawable: XcbDrawable,
		width: u16,
		height: u16,
		depth: u8,
		shm_seg: XcbShmSeg,
		offset: u32,
	) -> XcbVoidCookie ---
	xcb_shm_put_image :: proc(
		connection: ^XcbConnection,
		drawable: XcbDrawable,
		gc: XcbGContext,
		total_width: u16,
		total_height: u16,
		src_x: u16,
		src_y: u16,
		src_width: u16,
		src_height: u16,
		dst_x: u16,
		dst_y: u16,
		depth: u8,
		format: XcbImageFormat,
		send_event: u8,
		shm_seg: XcbShmSeg,
		offset: u32,
	) -> XcbVoidCookie ---
}

IPC_RMID :: 0x0
IPC_PRIVATE :: 0x0

S_IRUSR :: 0x00000100
S_IWUSR :: 0x00000080
S_IRGRP :: 0x00000020
S_IWGRP :: 0x00000010
S_IROTH :: 0x00000004
S_IWOTH :: 0x00000002
IPC_CREAT :: 0x00000200
IPC_EXCL :: 0x00000400
SHM_TS_NP :: 0x00010000
SHM_RESIZE_NP :: 0x00040000
SHM_MAP_FIXED_NP :: 0x00100000

foreign import shm "system:c"
@(default_calling_convention = "std")
foreign shm {
	shmat :: proc(shm_id: i32, shm_addr: rawptr, shm_flag: i32) -> rawptr ---
	shmctl :: proc(shm_id: i32, cmd: i32, buf: rawptr) -> i32 ---
	shmdt :: proc(shm_addr: rawptr) -> i32 ---
	shmget :: proc(key: u32, size: u32, shm_flag: i32) -> i32 ---
}

// TODO: Improve with create/destroy etc.
Backbuffer :: struct {
	memory:      rawptr,
	shm_seg_id:  XcbShmSeg,
	pixmap_id:   XcbPixmap,
	shm_id:      i32,
	width:       u16,
	height:      u16,
	bps:         u32,
	pitch:       u32,
}

resize_backbuffer :: proc(backbuffer: ^Backbuffer, connection: ^XcbConnection, window: XcbWindow, width: u32, height: u32) {
	if backbuffer.shm_seg_id == 0 {
		backbuffer.shm_seg_id = XcbShmSeg(xcb_generate_id(connection))
		backbuffer.pixmap_id = XcbPixmap(xcb_generate_id(connection))
	} else {
		shmctl(backbuffer.shm_id, IPC_RMID, nil)
		shmdt(backbuffer.memory)
		xcb_shm_detach(connection, backbuffer.shm_seg_id)
		xcb_free_pixmap(connection, backbuffer.pixmap_id)
	}
	xcb_flush(connection)

	backbuffer.width = 1280
	backbuffer.height = 720
	backbuffer.bps = 4
	backbuffer.pitch = u32(backbuffer.width) * u32(backbuffer.height)

	backbuffer.shm_id = shmget(IPC_PRIVATE, u32(backbuffer.bps * backbuffer.pitch), IPC_CREAT | 0o600)
	backbuffer.memory = shmat(backbuffer.shm_id, nil, 0)

	xcb_shm_attach(connection, backbuffer.shm_seg_id, u32(backbuffer.shm_id), 0)
	screen := xcb_setup_roots_iterator(xcb_get_setup(connection)).data
	xcb_shm_create_pixmap(
		connection,
		backbuffer.pixmap_id,
		XcbDrawable(window),
		backbuffer.width,
		backbuffer.height,
		screen.root_depth,
		backbuffer.shm_seg_id,
		0,
	)
}

main :: proc() {
	fmt.println("Hellope!")

	connection := xcb_connect(nil, nil)
	defer xcb_disconnect(connection)
	fmt.printf("connection %x\n", connection)

	setup := xcb_get_setup(connection)
	fmt.printf("setup %v\n", setup)

	screen := xcb_setup_roots_iterator(xcb_get_setup(connection)).data
	fmt.printf("screen %v\n", screen)

	window := XcbWindow(xcb_generate_id(connection))
	fmt.printf("window %v\n", window)

	mask: u32
	values: [2]u32
	mask = u32(XcbCW.Event_Mask)
	values[0] = u32(XcbEventMask.Exposure | XcbEventMask.Key_Press | XcbEventMask.Key_Release)
	xcb_create_window(
		connection,
		XCB_COPY_FROM_PARENT,
		window,
		screen.root,
		0,
		0,
		1280,
		720,
		10,
		.Input_Output,
		screen.root_visual,
		mask,
		&values[0],
	)
	defer xcb_destroy_window(connection, window)

	gcontext := XcbGContext(xcb_generate_id(connection))
	xcb_create_gc(connection, gcontext, XcbDrawable(window), 0, nil)

	// NOTE: Make sure we get the close window event (when letting decorations close the window etc).
	protocol_reply := xcb_intern_atom_reply(
		connection,
		xcb_intern_atom(connection, 1, 12, "WM_PROTOCOLS"),
		nil,
	)
	delete_window_reply := xcb_intern_atom_reply(
		connection,
		xcb_intern_atom(connection, 0, 16, "WM_DELETE_WINDOW"),
		nil,
	)
	xcb_change_property(
		connection,
		.Replace,
		window,
		protocol_reply.atom,
		.Atom,
		32,
		1,
		&delete_window_reply.atom,
	)

	xcb_map_window(connection, window)
	xcb_flush(connection)

	// NOTE: SHM support check.
	if reply := xcb_shm_query_version_reply(
		   connection,
		   xcb_shm_query_version(connection),
		   nil,
	   ); reply == nil || reply.shared_pixmaps == 0 {
		fmt.printf("Shm missing?\n")
	} else {
		fmt.printf("Shm: %v\n", reply)
	}

	key_syms := xcb_key_symbols_alloc(connection)
	defer xcb_key_symbols_free(key_syms)

	backbuffer: Backbuffer
	fmt.printf("backbuffer: %+v\n", backbuffer)
	resize_backbuffer(&backbuffer, connection, window, 1280, 720)
	defer shmctl(backbuffer.shm_id, IPC_RMID, nil)
	defer shmdt(backbuffer.memory)
	defer xcb_shm_detach(connection, backbuffer.shm_seg_id)
	defer xcb_free_pixmap(connection, backbuffer.pixmap_id)
	fmt.printf("backbuffer: %+v\n", backbuffer)

	shm_completion_event := xcb_get_extension_data(connection, &xcb_shm_id).first_event + XCB_SHM_COMPLETION
	fmt.printf("completion event: %d\n", shm_completion_event)

	is_running := true
	ready_to_blit := true
	for is_running {

		event: ^XcbGenericEvent = xcb_poll_for_event(connection)
		for ; event != nil; event = xcb_poll_for_event(connection) {
			switch (event.response_type & ~u8(0x80)) {
			case 0:
				err := (^XcbGenericError)(event)
				err_ctx: ^XcbErrorsContext
				xcb_errors_context_new(connection, &err_ctx)
				major := xcb_errors_get_name_for_major_code(err_ctx, u8(err.major_code))
				minor := xcb_errors_get_name_for_minor_code(err_ctx, u8(err.major_code), err.minor_code)
				extension: cstring
				error := xcb_errors_get_name_for_error(err_ctx, err.error_code, &extension)
				fmt.printf(
					"XCB Error: %s:%s, %s:%s, resource %u sequence %u\n",
					error,
					extension != nil ? extension : "no_extension",
					major,
					minor != nil ? minor : "no_minor",
					err.resource_id,
					err.sequence,
				)
				xcb_errors_context_free(err_ctx)

			case XCB_EXPOSE:
				fmt.printf("XCB_EXPOSE\n")

			case XCB_KEY_PRESS, XCB_KEY_RELEASE:
				fmt.printf("XCB_KEY_PRESS/RELEASE\n")
				if (event.response_type == XCB_KEY_PRESS) {
					evt := (^XcbKeyPressEvent)(event)
					key_sym := xcb_key_press_lookup_keysym(key_syms, evt, 0)

					// NOTE: 0xff1b == XK_escape
					fmt.printf("KEY DOWN: %v %d ?= %d\n", evt, key_sym, 0xff1b)
					if key_sym == 0xff1b {
						is_running = false
					}
				}

			case XCB_CLIENT_MESSAGE:
				fmt.printf("XCB_CLIENT_MESSAGE\n")
				evt := (^XcbClientMessageEvent)(event)
				if evt.data.data32[0] == u32(delete_window_reply.atom) {
					is_running = false
				}

			case shm_completion_event:
				ready_to_blit = true

			case:
				fmt.printf("unexpected event %v\n", event)
			}


			libc.free(event)
		}

		screen_buffer := Bitmap {
			buffer = ([^]u32)(backbuffer.memory)[0:backbuffer.pitch],
			width  = u32(backbuffer.width),
			height = u32(backbuffer.height),
		}
		app_update_and_render(&screen_buffer)

		if ready_to_blit {
			ready_to_blit = false

			xcb_shm_put_image(
				connection,
				XcbDrawable(window),
				gcontext,
				backbuffer.width,
				backbuffer.height,
				0,
				0,
				backbuffer.width,
				backbuffer.height,
				0,
				0,
				screen.root_depth,
				.z_pixmap,
				1,
				backbuffer.shm_seg_id,
				0,
			)

			xcb_flush(connection)
		}
	}
}
