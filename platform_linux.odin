package main

import "core:fmt"
import "core:c"

foreign import xcb "system:xcb"

XcbConnection :: struct {}

XcbKeycode :: distinct u8

XcbSetup :: struct {
  status: u8,
  pad0: u8,
  protocol_major_version: u16,
  protocol_minor_version: u16,
  length: u16,
  release_number: u32,
  resource_id_base: u32,
  resource_id_mask: u32,
  motion_buffer_size: u32,
  vendor_len: u16,
  maximum_request_length: u16,
  roots_len: u8,
  pixmap_formats_len: u8,
  image_byte_order: u8,
  bitmap_format_bit_order: u8,
  bitmap_format_scanline_unit: u8,
  bitmap_format_scanline_pad: u8,
  min_keycode: XcbKeycode,
  max_keycode: XcbKeycode,
  pad1: [4]u8,
}

XcbWindow :: distinct u32

XcbColorMap :: distinct u32

XcbVisualId :: distinct u32

XcbScreen :: struct {
  root: XcbWindow,
  default_colormap: XcbColorMap,
  white_pixel: u32,
  black_pixel: u32,
  current_input_masks: u32,
  width_in_pixels: u16,
  height_in_pixels: u16,
  width_in_millimeters: u16,
  height_in_millimeters: u16,
  min_installed_maps: u16,
  max_installed_maps: u16,
  root_visual: XcbVisualId,
  backing_stores: u8,
  save_unders: u8,
  root_depth: u8,
  allowed_depths_len: u8,
}

XcbScreenIterator :: struct {
  data: ^XcbScreen,
  rem: u32,
  index: u32,
}

@(default_calling_convention="std")
foreign xcb {
  xcb_connect :: proc(display_name: cstring, screen_p: ^c.int) -> ^XcbConnection ---
  xcb_get_setup :: proc(connection: ^XcbConnection) -> ^XcbSetup ---
  xcb_setup_roots_iterator :: proc(setup: ^XcbSetup) -> ^XcbScreenIterator ---
}

main :: proc() {
  fmt.println("Hellope!")

  connection := xcb_connect(nil, nil)
  fmt.printf("connection %x\n", connection)

  setup := xcb_get_setup(connection)
  fmt.printf("setup %v\n", setup)

  roots := xcb_setup_roots_iterator(xcb_get_setup(connection))
  fmt.printf("roots %v\n", roots)
  fmt.printf("roots %v\n", roots^)
  // xcb_screen_t*     screen = xcb_setup_roots_iterator(xcb_get_setup(conn)).data;
}
