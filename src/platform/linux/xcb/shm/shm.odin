package xcb_shm

import xcb "../"

Seg :: distinct u32

QueryVersionCookie :: struct {
	sequence: u32,
}

QueryVersionReply :: struct {
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

Id := xcb.Extension {
	name      = "MIT-SHM",
	global_id = 0,
}

COMPLETION :: 0

foreign import xcb_shm "system:xcb-shm"
@(default_calling_convention = "std")
@(link_prefix = "xcb_shm_")
foreign xcb_shm {
	query_version :: proc(connection: ^xcb.Connection) -> QueryVersionCookie ---
	query_version_reply :: proc(
		connection: ^xcb.Connection,
		cookie: QueryVersionCookie,
		err: ^^xcb.GenericError,
	) -> ^QueryVersionReply ---
	attach :: proc(
		connection: ^xcb.Connection,
		shm_seg: Seg,
		shm_id: u32,
		read_only: u8,
	) -> xcb.VoidCookie ---
	detach :: proc(connection: ^xcb.Connection, shm_seg: Seg) -> xcb.VoidCookie ---
	create_pixmap :: proc(
		connection: ^xcb.Connection,
		pixmap: xcb.Pixmap,
		drawable: xcb.Drawable,
		width: u16,
		height: u16,
		depth: u8,
		shm_seg: Seg,
		offset: u32,
	) -> xcb.VoidCookie ---
	put_image :: proc(
		connection: ^xcb.Connection,
		drawable: xcb.Drawable,
		gc: xcb.Gcontext,
		total_width: u16,
		total_height: u16,
		src_x: u16,
		src_y: u16,
		src_width: u16,
		src_height: u16,
		dst_x: u16,
		dst_y: u16,
		depth: u8,
		format: xcb.ImageFormat,
		send_event: u8,
		shm_seg: Seg,
		offset: u32,
	) -> xcb.VoidCookie ---
}
