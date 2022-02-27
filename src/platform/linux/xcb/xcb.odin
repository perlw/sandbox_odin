package xcb

COPY_FROM_PARENT: u8 : 0

VoidCookie :: struct {
	sequence: u32,
}

InternAtomCookie :: struct {
	using void: VoidCookie,
}

GenericError :: struct {
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

GenericEvent :: struct {
	response_type: u8,
	pad0:          u8,
	sequence:      u16,
	pad:           [7]u32,
	full_sequence: u32,
}

foreign import xcb "system:xcb"
@(default_calling_convention = "std")
@(link_prefix = "xcb_")
foreign xcb {
	connect :: proc(display_name: cstring, screen_p: ^u32) -> ^Connection ---
	disconnect :: proc(connection: ^Connection) ---

	get_setup :: proc(connection: ^Connection) -> ^Setup ---

	generate_id :: proc(connection: ^Connection) -> u32 ---
	flush :: proc(conncetion: ^Connection) -> u32 ---
	poll_for_event :: proc(connection: ^Connection) -> ^GenericEvent ---

	get_extension_data :: proc(connection: ^Connection, ext: ^Extension) -> ^QueryExtensionReply ---
}
