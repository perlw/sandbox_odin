package xcb

import "core:c/libc"

free_generic_event :: proc(event: ^GenericEvent) {
	libc.free(event)
}
