//+build linux
package main

import "core:fmt"
import "core:time"

import "platform/linux/shm"
import "platform/linux/xcb"
import xcbshm "platform/linux/xcb/shm"
import xcbkeysyms "platform/linux/xcb/keysyms"
import xcberrors "platform/linux/xcb/errors"

foreign import unistd "system:c"
@(default_calling_convention = "std")
foreign unistd {
	usleep :: proc(usecs: u64) -> i32 ---
}


// TODO: Improve with create/destroy etc.
Backbuffer :: struct {
	memory:      rawptr,
	shm_seg_id:  xcbshm.Seg,
	pixmap_id:   xcb.Pixmap,
	shm_id:      i32,
	width:       u16,
	height:      u16,
	bps:         u32,
	pitch:       u32,
}

resize_backbuffer :: proc(backbuffer: ^Backbuffer, connection: ^xcb.Connection, window: xcb.Window, width, height: u32) {
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

	backbuffer.width = 1280
	backbuffer.height = 720
	backbuffer.bps = 4
	backbuffer.pitch = u32(backbuffer.width) * u32(backbuffer.height)

	backbuffer.shm_id = shm.get(shm.IPC_PRIVATE, u32(backbuffer.bps * backbuffer.pitch), shm.IPC_CREAT | 0o600)
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

	mask : u32
	values : [2]u32
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

	backbuffer : Backbuffer
	fmt.printf("backbuffer: %+v\n", backbuffer)
	resize_backbuffer(&backbuffer, connection, window, 1280, 720)
	defer shm.ctl(backbuffer.shm_id, shm.IPC_RMID, nil)
	defer shm.dt(backbuffer.memory)
	defer xcbshm.detach(connection, backbuffer.shm_seg_id)
	defer xcb.free_pixmap(connection, backbuffer.pixmap_id)
	fmt.printf("backbuffer: %+v\n", backbuffer)

	shm_completion_event := xcb.get_extension_data(connection, &xcbshm.Id).first_event + xcbshm.COMPLETION
	fmt.printf("completion event: %d\n", shm_completion_event)

	game_update_hz := f32(30)
	target_seconds_per_frame := 1.0 / game_update_hz
	last_counter := get_clock_value()
	ms_per_frame : f32
	second : f32

	is_running := true
	ready_to_blit := true
	for is_running {
		event := xcb.poll_for_event(connection)
		for ; event != nil; event = xcb.poll_for_event(connection) {
			switch (event.response_type & ~u8(0x80)) {
			case 0:
				err := (^xcb.GenericError)(event)
				err_ctx : ^xcberrors.Context
				xcberrors.context_new(connection, &err_ctx)
				major := xcberrors.get_name_for_major_code(err_ctx, u8(err.major_code))
				minor := xcberrors.get_name_for_minor_code(err_ctx, u8(err.major_code), err.minor_code)
				extension : cstring
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

					// NOTE: 0xff1b == XK_escape
					fmt.printf("KEY DOWN: %v %d ?= %d\n", evt, key_sym, 0xff1b)
					if key_sym == 0xff1b {
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
		update_and_render_timing_start := get_clock_value()
		app_update_and_render(&screen_buffer)
		update_and_render_timing_end := get_clock_value()

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
			fmt.printf("missed sleep\n")
		}
		end_counter := get_clock_value()
		ms_per_frame = 1000.0 * get_seconds_elapsed(last_counter, end_counter)
		second += get_seconds_elapsed(last_counter, end_counter)
		last_counter = end_counter
		if second > 1 {
			second = 0
			fmt.printf("last. ms/frame: %f\n", ms_per_frame)
			fmt.printf(
				"last. ms/render: %f\n",
				1000.0 * get_seconds_elapsed(update_and_render_timing_start, update_and_render_timing_end),
			)
		}
	}
}
