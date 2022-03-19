//+build linux
package main

import "core:fmt"
import "core:time"

import "platform/linux/shm"
import "platform/linux/xcb"
import xcbshm "platform/linux/xcb/shm"
import xcbkeysyms "platform/linux/xcb/keysyms"
import xcberrors "platform/linux/xcb/errors"
import "platform/linux/X11"

foreign import unistd "system:c"
@(default_calling_convention = "std")
foreign unistd {
	usleep :: proc(usecs: u64) -> i32 ---
}

DEBUG_DRAW_TIMINGS :: #config(DEBUG_DRAW_TIMINGS, false)

// TODO: Improve with create/destroy etc.
Backbuffer :: struct {
	memory:     rawptr,
	shm_seg_id: xcbshm.Seg,
	pixmap_id:  xcb.Pixmap,
	shm_id:     i32,
	width:      u16,
	height:     u16,
	bps:        u8,
	pitch:      u32,
}

resize_backbuffer :: proc(
	backbuffer: ^Backbuffer,
	connection: ^xcb.Connection,
	window: xcb.Window,
	width,
	height: u16,
) {
	if backbuffer.shm_seg_id == 0 {
		backbuffer.shm_seg_id = xcbshm.Seg(xcb.generate_id(connection))
		backbuffer.pixmap_id = xcb.Pixmap(xcb.generate_id(connection))
	} else {
		shm.ctl(backbuffer.shm_id, shm.IPC_RMID, nil)
		shm.dt(backbuffer.memory)
		xcbshm.detach(connection, backbuffer.shm_seg_id)
		xcb.free_pixmap(connection, backbuffer.pixmap_id)
	}
	xcb.flush(connection)

	backbuffer.width = width
	backbuffer.height = height
	backbuffer.bps = 4
	backbuffer.pitch = u32(backbuffer.width) * u32(backbuffer.height)

	backbuffer.shm_id = shm.get(
		shm.IPC_PRIVATE,
		u32(backbuffer.bps) * backbuffer.pitch,
		shm.IPC_CREAT | 0o600,
	)
	backbuffer.memory = shm.at(backbuffer.shm_id, nil, 0)

	xcbshm.attach(connection, backbuffer.shm_seg_id, u32(backbuffer.shm_id), 0)
	screen := xcb.setup_roots_iterator(xcb.get_setup(connection)).data
	xcbshm.create_pixmap(
		connection,
		backbuffer.pixmap_id,
		xcb.Drawable(window),
		backbuffer.width,
		backbuffer.height,
		screen.root_depth,
		backbuffer.shm_seg_id,
		0,
	)
}

get_clock_value :: #force_inline proc() -> time.TimeSpec {
	return time.clock_gettime(time.CLOCK_MONOTONIC_RAW)
}

get_seconds_elapsed :: #force_inline proc(start, end: time.TimeSpec) -> f32 {
	return f32(end.tv_sec - start.tv_sec) + (f32(end.tv_nsec - start.tv_nsec) / 1000000000.0)
}

main :: proc() {
	fmt.println("Hellope!")

	connection := xcb.connect(nil, nil)
	defer xcb.disconnect(connection)
	fmt.printf("connection %x\n", connection)

	setup := xcb.get_setup(connection)
	fmt.printf("setup %v\n", setup)

	screen := xcb.setup_roots_iterator(xcb.get_setup(connection)).data
	fmt.printf("screen %v\n", screen)

	window := xcb.Window(xcb.generate_id(connection))
	fmt.printf("window %v\n", window)

	mask: u32
	values: [2]u32
	mask = u32(xcb.Cw.Event_Mask)
	values[0] = u32(xcb.EventMask.Exposure | xcb.EventMask.Key_Press | xcb.EventMask.Key_Release)
	xcb.create_window(
		connection,
		xcb.COPY_FROM_PARENT,
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
	defer xcb.destroy_window(connection, window)

	gcontext := xcb.Gcontext(xcb.generate_id(connection))
	xcb.create_gc(connection, gcontext, xcb.Drawable(window), 0, nil)

	// NOTE: Make sure we get the close window event (when letting decorations close the window etc).
	protocol_reply := xcb.intern_atom_reply(
		connection,
		xcb.intern_atom(connection, 1, 12, "WM_PROTOCOLS"),
		nil,
	)
	delete_window_reply := xcb.intern_atom_reply(
		connection,
		xcb.intern_atom(connection, 0, 16, "WM_DELETE_WINDOW"),
		nil,
	)
	xcb.change_property(
		connection,
		.Replace,
		window,
		protocol_reply.atom,
		.Atom,
		32,
		1,
		&delete_window_reply.atom,
	)

	xcb.map_window(connection, window)
	xcb.flush(connection)

	// NOTE: SHM support check.
	if reply := xcbshm.query_version_reply(
		   connection,
		   xcbshm.query_version(connection),
		   nil,
	   ); reply == nil || reply.shared_pixmaps == 0 {
		fmt.printf("Shm missing?\n")
	} else {
		fmt.printf("Shm: %v\n", reply)
	}

	key_syms := xcbkeysyms.symbols_alloc(connection)
	defer xcbkeysyms.symbols_free(key_syms)

	backbuffers: [2]Backbuffer
	backbuffer_index := 0
	resize_backbuffer(&backbuffers[0], connection, window, 1280, 720)
	resize_backbuffer(&backbuffers[1], connection, window, 1280, 720)
	defer shm.ctl(backbuffers[0].shm_id, shm.IPC_RMID, nil)
	defer shm.dt(backbuffers[0].memory)
	defer xcbshm.detach(connection, backbuffers[0].shm_seg_id)
	defer xcb.free_pixmap(connection, backbuffers[0].pixmap_id)

	defer shm.ctl(backbuffers[1].shm_id, shm.IPC_RMID, nil)
	defer shm.dt(backbuffers[1].memory)
	defer xcbshm.detach(connection, backbuffers[1].shm_seg_id)
	defer xcb.free_pixmap(connection, backbuffers[1].pixmap_id)
	fmt.printf("backbuffer[0]: %+v\n", backbuffers[0])
	fmt.printf("backbuffer[1]: %+v\n", backbuffers[1])

	shm_completion_event := xcb.get_extension_data(connection, &xcbshm.Id).first_event + xcbshm.COMPLETION
	fmt.printf("completion event: %d\n", shm_completion_event)

	game_update_hz := f32(30)
	target_seconds_per_frame := 1.0 / game_update_hz
	last_counter := get_clock_value()

	when DEBUG_DRAW_TIMINGS {
		debug_frame_timings: [256]f32
		debug_render_timings: [256]f32
		debug_highest_timing := f32(1)
	}

	is_running := true
	ready_to_blit := true
	backbuffer := backbuffers[backbuffer_index]
	for is_running {
		event := xcb.poll_for_event(connection)
		for ; event != nil; event = xcb.poll_for_event(connection) {
			switch (event.response_type & ~u8(0x80)) {
			case 0:
				err := (^xcb.GenericError)(event)
				err_ctx: ^xcberrors.Context
				xcberrors.context_new(connection, &err_ctx)
				major := xcberrors.get_name_for_major_code(err_ctx, u8(err.major_code))
				minor := xcberrors.get_name_for_minor_code(err_ctx, u8(err.major_code), err.minor_code)
				extension: cstring
				error := xcberrors.get_name_for_error(err_ctx, err.error_code, &extension)
				fmt.printf(
					"XCB Error: %s:%s, %s:%s, resource %u sequence %u\n",
					error,
					extension != nil ? extension : "no_extension",
					major,
					minor != nil ? minor : "no_minor",
					err.resource_id,
					err.sequence,
				)
				xcberrors.context_free(err_ctx)

			case xcb.EXPOSE:
				fmt.printf("XCB_EXPOSE\n")

			case xcb.KEY_PRESS, xcb.KEY_RELEASE:
				fmt.printf("XCB_KEY_PRESS/RELEASE\n")
				if (event.response_type == xcb.KEY_PRESS) {
					evt := (^xcb.KeyPressEvent)(event)
					key_sym := xcbkeysyms.press_lookup_keysym(key_syms, evt, 0)

					fmt.printf("KEY DOWN: %v %d ?= %d\n", evt, key_sym, X11.KeyCode.Escape)
					if key_sym == u32(X11.KeyCode.Escape) {
						is_running = false
					}
				}

			case xcb.CLIENT_MESSAGE:
				fmt.printf("XCB_CLIENT_MESSAGE\n")
				evt := (^xcb.ClientMessageEvent)(event)
				if evt.data.data32[0] == u32(delete_window_reply.atom) {
					is_running = false
				}

			case shm_completion_event:
				ready_to_blit = true

			case:
				fmt.printf("unexpected event %v\n", event)
			}

			xcb.free_generic_event(event)
		}

		screen_buffer := Bitmap {
			buffer = ([^]u32)(backbuffer.memory)[0:backbuffer.pitch],
			width  = u32(backbuffer.width),
			height = u32(backbuffer.height),
		}
		when DEBUG_DRAW_TIMINGS {
			update_and_render_timing_start := get_clock_value()
		}
		app_update_and_render(&screen_buffer)
		when DEBUG_DRAW_TIMINGS {
			update_and_render_timing_stop := get_clock_value()
		}

		when DEBUG_DRAW_TIMINGS {
			pix_step := 128 / debug_highest_timing
			target_ms := 1000 * target_seconds_per_frame
			target_ms_line := int(((target_ms * (target_ms / debug_highest_timing)) * pix_step) + 0.5)
			for x := 0; x < 256; x += 1 {
				frame_height: int
				render_height: int
				{
					scaling := debug_frame_timings[x] / debug_highest_timing
					frame_height = int(((debug_frame_timings[x] * scaling) * pix_step) + 0.5)
				}
				{
					scaling := debug_render_timings[x] / debug_highest_timing
					render_height = int(((debug_render_timings[x] * scaling) * pix_step) + 0.5)
				}

				for y := 0; y < 128; y += 1 {
					i := ((127 - y) * int(screen_buffer.width)) + x

					c: u32 = 0xFF000000
					if y == target_ms_line {
						c = 0xFFFF00FF
					} else if y <= render_height {
						if render_height > target_ms_line {
							c = 0xFFFF0000
						} else {
							c = 0xFF00AA00
						}
					} else if y <= frame_height {
						c = 0xFF0000AA
					}
					screen_buffer.buffer[i] = c
				}
			}
		}

		if ready_to_blit {
			ready_to_blit = false

			xcbshm.put_image(
				connection,
				xcb.Drawable(window),
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

			xcb.flush(connection)

			backbuffer_index = (backbuffer_index + 1) % 2
			backbuffer = backbuffers[backbuffer_index]
		}

		elapsed := get_seconds_elapsed(last_counter, get_clock_value())
		if elapsed < target_seconds_per_frame {
			sleep_mics := u64(1000000 * (target_seconds_per_frame - elapsed))
			if sleep_mics > 0 {
				usleep(sleep_mics)
			}

			for elapsed < target_seconds_per_frame {
				elapsed = get_seconds_elapsed(last_counter, get_clock_value())
			}
		} else {
			// fmt.printf("missed sleep\n")
		}

		end_counter := get_clock_value()

		when DEBUG_DRAW_TIMINGS {
			ms_per_frame := 1000.0 * get_seconds_elapsed(last_counter, end_counter)
			frame_render_ms := 1000.0 * get_seconds_elapsed(
	                      update_and_render_timing_start,
	                      update_and_render_timing_stop,
                      )

			debug_highest_timing = 0
			for i := 0; i < 255; i += 1 {
				debug_frame_timings[i] = debug_frame_timings[i + 1]
				if debug_frame_timings[i] > debug_highest_timing {
					debug_highest_timing = debug_frame_timings[i]
				}
				debug_render_timings[i] = debug_render_timings[i + 1]
				if debug_render_timings[i] > debug_highest_timing {
					debug_highest_timing = debug_render_timings[i]
				}
			}
			debug_frame_timings[255] = ms_per_frame
			if ms_per_frame > debug_highest_timing {
				debug_highest_timing = ms_per_frame
			}
			debug_render_timings[255] = frame_render_ms
			if frame_render_ms > debug_highest_timing {
				debug_highest_timing = frame_render_ms
			}
		}

		last_counter = end_counter
	}
}
