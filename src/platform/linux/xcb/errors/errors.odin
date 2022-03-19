// NOTE: Based on <xcb/xcb_errors.h>
package xcb_errors

import xcb "../"

Context :: struct {}

foreign import xcb_errors "system:xcb-errors"
@(default_calling_convention = "std")
@(link_prefix = "xcb_errors_")
foreign xcb_errors {
	context_new :: proc(connection: ^xcb.Connection, ctx: ^^Context) -> u32 ---
	get_name_for_major_code :: proc(ctx: ^Context, major_code: u8) -> cstring ---
	get_name_for_minor_code :: proc(ctx: ^Context, major_code: u8, minor_code: u16) -> cstring ---
	get_name_for_error :: proc(ctx: ^Context, error_code: u8, extension: ^cstring) -> cstring ---
	context_free :: proc(ctx: ^Context) ---
}
