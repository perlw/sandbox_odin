//+build windows
package main

import "core:fmt"
import "core:sys/win32"

WIN32_CLASS_NAME :: cstring("sandboxwin32platform_odin")

global_is_running := true

window_proc :: proc "std" (
	hwnd: win32.Hwnd,
	msg: u32,
	wparam: win32.Wparam,
	lparam: win32.Lparam,
) -> win32.Lresult {
	result: win32.Lresult

	switch msg {
	case win32.WM_DESTROY:
		global_is_running = false
		win32.output_debug_string_a("WM_DESTROY\n")

	case win32.WM_CLOSE:
		global_is_running = false
		win32.output_debug_string_a("WM_CLOSE\n")

	case:
		result = win32.def_window_proc_a(hwnd, msg, wparam, lparam)
	}

	return result
}

Backbuffer :: struct {
	memory:      rawptr,
	bitmap_info: win32.Bitmap_Info,
	width:       u32,
	height:      u32,
	bps:         u32,
	pitch:       u32,
}

resize_backbuffer :: proc(backbuffer: ^Backbuffer, width: u32, height: u32) {
	if backbuffer.memory != nil {
		win32.virtual_free(backbuffer.memory, 0, win32.MEM_RELEASE)
	}

	backbuffer.width = width
	backbuffer.height = height
	backbuffer.bps = 4
	backbuffer.pitch = width * height

	backbuffer.bitmap_info.header = {
		size        = size_of(backbuffer.bitmap_info.header),
		width       = i32(width),
		height      = -i32(height),
		planes      = 1,
		bit_count   = 32,
		compression = win32.BI_RGB,
	}

	backbuffer.memory = win32.virtual_alloc(
		nil,
		uint(backbuffer.bps * backbuffer.pitch),
		win32.MEM_RESERVE | win32.MEM_COMMIT,
		win32.PAGE_READWRITE,
	)
}

get_clock_value :: #force_inline proc() -> i64 {
	result: i64
	win32.query_performance_counter(&result)
	return result
}

global_perf_count_frequency: i64

get_seconds_elapsed :: #force_inline proc(start, end: i64) -> f32 {
	return f32(end - start) / f32(global_perf_count_frequency)
}

blit_buffer_in_window :: proc(backbuffer: ^Backbuffer, dc: win32.Hdc, width, height: i32) {
	ratio: f32 : 16.0 / 9.0
	fixed_width := i32(f32(height) * ratio)
	offset_x := (width - fixed_width) / 2

	if fixed_width != width {
		win32.pat_blt(dc, 0, 0, offset_x, height, win32.BLACKNESS)
		win32.pat_blt(dc, width - offset_x, 0, offset_x, height, win32.BLACKNESS)
	}
	win32.stretch_dibits(
		dc,
		offset_x,
		0,
		fixed_width,
		height,
		0,
		0,
		i32(backbuffer.width),
		i32(backbuffer.height),
		backbuffer.memory,
		&backbuffer.bitmap_info,
		win32.DIB_RGB_COLORS,
		win32.SRCCOPY,
	)
}

TIMERR_BASE :: 96
TIMERR_NOCANDO :: TIMERR_BASE + 1
TIMERR_NOERROR :: 0

main :: proc() {
	fmt.println("Hellope!")

	hinstance := win32.get_module_handle_a(nil)
	fmt.printf("hinstance %x\n", hinstance)

	global_perf_count_frequency = win32.get_query_performance_frequency()
	fmt.printf("perf_count_frequency: %d\n", global_perf_count_frequency)

	sleep_is_granular := (win32.time_begin_period(1) == TIMERR_NOERROR)
	if sleep_is_granular {
		fmt.printf("-=sleep is granular=-\n")
	}

	window_class := win32.Wnd_Class_A {
		style      = win32.CS_OWNDC | win32.CS_HREDRAW | win32.CS_VREDRAW,
		wnd_proc   = window_proc,
		instance   = win32.Hinstance(hinstance),
		cursor     = win32.load_cursor_a(nil, win32.IDC_ARROW),
		class_name = WIN32_CLASS_NAME,
	}
	fmt.printf("window_class %v\n", window_class)

	if win32.register_class_a(&window_class) == 0 {
		win32.output_debug_string_a("could not register class\n")
	}

	wsize := win32.Rect {
		right  = 1280,
		bottom = 720,
	}
	win32.adjust_window_rect(&wsize, win32.WS_OVERLAPPEDWINDOW, false)
	fmt.printf("adjusted wndrect %v\n", wsize)

	window := win32.create_window_ex_a(
		0,
		WIN32_CLASS_NAME,
		"odin-lang hello winapi",
		win32.WS_OVERLAPPEDWINDOW | win32.WS_VISIBLE,
		win32.CW_USEDEFAULT,
		win32.CW_USEDEFAULT,
		wsize.right - wsize.left,
		wsize.bottom - wsize.top,
		nil,
		nil,
		win32.Hinstance(hinstance),
		nil,
	)

	if window == nil {
		win32.output_debug_string_a("could not create window\n")
		return
	}
	defer win32.destroy_window(window)

	backbuffer: Backbuffer
	fmt.printf("backbuffer: %+v\n", backbuffer)
	resize_backbuffer(&backbuffer, 1280, 720)
	defer win32.virtual_free(backbuffer.memory, 0, win32.MEM_RELEASE)
	fmt.printf("backbuffer: %+v\n", backbuffer)

	game_update_hz := f32(30)
	target_seconds_per_frame := 1.0 / game_update_hz
	last_counter := get_clock_value()
	ms_per_frame: f32
	second: f32

	for global_is_running {
		message: win32.Msg
		for win32.peek_message_a(&message, window, 0, 0, win32.PM_REMOVE) {
			switch message.message {
			case win32.WM_QUIT:
				global_is_running = false
				win32.output_debug_string_a("WM_QUIT\n")

			case win32.WM_SYSKEYDOWN, win32.WM_SYSKEYUP, win32.WM_KEYDOWN, win32.WM_KEYUP:
				win32.output_debug_string_a("WM_SYS/KEY\n")
				if message.wparam == win32.VK_ESCAPE {
					global_is_running = false
				}

			case:
				win32.translate_message(&message)
				win32.dispatch_message_a(&message)
			}
		}

		screen_buffer := Bitmap {
			buffer = ([^]u32)(backbuffer.memory)[0:backbuffer.pitch],
			width  = backbuffer.width,
			height = backbuffer.height,
		}
		update_and_render_timing_start := get_clock_value()
		app_update_and_render(&screen_buffer)
		update_and_render_timing_end := get_clock_value()

		dc := win32.get_dc(window)
		client_rect: win32.Rect
		win32.get_client_rect(window, &client_rect)
		dim_width := client_rect.right - client_rect.left
		dim_height := client_rect.bottom - client_rect.top
		blit_buffer_in_window(&backbuffer, dc, dim_width, dim_height)
		win32.release_dc(window, dc)

		elapsed := get_seconds_elapsed(last_counter, get_clock_value())
		if elapsed < target_seconds_per_frame {
			if sleep_is_granular {
				sleep_ms := u32(1000 * (target_seconds_per_frame - elapsed))
				if sleep_ms > 0 {
					win32.sleep(sleep_ms)
				}
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
