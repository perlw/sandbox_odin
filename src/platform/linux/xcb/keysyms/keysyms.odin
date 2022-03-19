// NOTE: Based on <xcb/xcb_keysyms.h>
package xcb_keysyms

import xcb "../"

Symbols :: struct {}
Sym :: u32

foreign import xcb_keysyms "system:xcb-keysyms"
@(default_calling_convention = "std")
@(link_prefix = "xcb_key_")
foreign xcb_keysyms {
	symbols_alloc :: proc(connection: ^xcb.Connection) -> ^Symbols ---
	symbols_free :: proc(symbols: ^Symbols) ---
	press_lookup_keysym :: proc(symbols: ^Symbols, event: ^xcb.KeyPressEvent, col: i32) -> Sym ---
	release_lookup_keysym :: proc(symbols: ^Symbols, event: ^xcb.KeyReleaseEvent, col: i32) -> Sym ---
}
