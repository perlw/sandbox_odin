package main

import "core:fmt"
import "core:c"

foreign import xcb "system:xcb"

XcbConnection :: struct {}

foreign xcb {
  xcb_connect :: proc(display_name: cstring, screen_p: ^c.int) -> ^XcbConnection ---
}


main :: proc() {
	fmt.println("Hellope!");

  connection := xcb_connect(nil, nil);
  fmt.printf("foo %x\n", connection);

  // xcb_screen_t*     screen = xcb_setup_roots_iterator(xcb_get_setup(conn)).data;
}
