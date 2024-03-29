//+build windows
package main

import "core:fmt"
import "core:sys/windows"

DEBUG_DRAW_TIMINGS :: #config(DEBUG_DRAW_TIMINGS, false)

global_is_running := true

window_proc :: proc "std" (
	hwnd: windows.HWND,
	msg: u32,
	wparam: windows.WPARAM,
	lparam: windows.LPARAM,
) -> windows.LRESULT {result: windows.LRESULT
	switch msg {
	case windows.WM_DESTROY:
		global_is_running = false
		msg := cstring("WM_DESTROY\n")
		windows.OutputDebugStringW(([^]u16)(&msg))

	case windows.WM_CLOSE:
		global_is_running = false
		msg := cstring("WM_CLOSE\n")
		windows.OutputDebugStringW(([^]u16)(&msg))

	case:
		result = windows.DefWindowProcW(hwnd, msg, wparam, lparam)
	}

	return result
}

Backbuffer :: struct {
	memory:      rawptr,
	bitmap_info: windows.BITMAPINFO,
	width:       u32,
	height:      u32,
	bps:         u32,
	pitch:       u32,
}

resize_backbuffer :: proc(backbuffer: ^Backbuffer, width: u32, height: u32) {
	if backbuffer.memory != nil {
		windows.VirtualFree(backbuffer.memory, 0, windows.MEM_RELEASE)
	}

	backbuffer.width = width
	backbuffer.height = height
	backbuffer.bps = 4
	backbuffer.pitch = width * height

	backbuffer.bitmap_info.bmiHeader = {
		biSize        = size_of(backbuffer.bitmap_info.bmiHeader),
		biWidth       = i32(width),
		biHeight      = -i32(height),
		biPlanes      = 1,
		biBitCount    = 32,
		biCompression = windows.BI_RGB,
	}

	backbuffer.memory = windows.VirtualAlloc(
		nil,
		uint(backbuffer.bps * backbuffer.pitch),
		windows.MEM_RESERVE | windows.MEM_COMMIT,
		windows.PAGE_READWRITE,
	)
}

get_clock_value :: #force_inline proc() -> i64 {
	result: windows.LARGE_INTEGER
	windows.QueryPerformanceCounter(&result)
	return i64(result)
}

global_perf_count_frequency: i64

get_seconds_elapsed :: #force_inline proc(start, end: i64) -> f32 {
	return f32(end - start) / f32(global_perf_count_frequency)
}

blit_buffer_in_window :: proc(backbuffer: ^Backbuffer, dc: windows.HDC, width, height: i32) {
	ratio: f32 : 16.0 / 9.0
	fixed_width := i32(f32(height) * ratio)
	offset_x := (width - fixed_width) / 2

	if fixed_width != width {
		windows.PatBlt(dc, 0, 0, offset_x, height, windows.BLACKNESS)
		windows.PatBlt(dc, width - offset_x, 0, offset_x, height, windows.BLACKNESS)
	}
	windows.StretchDIBits(
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
		windows.DIB_RGB_COLORS,
		windows.SRCCOPY,
	)
}

TIMERR_BASE :: 96
TIMERR_NOCANDO :: TIMERR_BASE + 1
TIMERR_NOERROR :: 0

input_key_translation := map[uint]AppInputKey {
	windows.VK_ESCAPE = .Escape,
	windows.VK_0      = .Num0,
	windows.VK_1      = .Num1,
	windows.VK_2      = .Num2,
	windows.VK_3      = .Num3,
	windows.VK_4      = .Num4,
	windows.VK_5      = .Num5,
	windows.VK_6      = .Num6,
	windows.VK_7      = .Num7,
	windows.VK_8      = .Num8,
	windows.VK_9      = .Num9,
}

main :: proc() {
	fmt.println("Hellope!")

	hinstance := windows.GetModuleHandleW(nil)
	fmt.printf("hinstance %x\n", hinstance)

	windows.QueryPerformanceFrequency(((^windows.LARGE_INTEGER)(&global_perf_count_frequency)))
	fmt.printf("perf_count_frequency: %d\n", global_perf_count_frequency)

	sleep_is_granular := (windows.timeBeginPeriod(1) == TIMERR_NOERROR)
	if sleep_is_granular {
		fmt.printf("-=sleep is granular=-\n")
	}

	class_name := windows.utf8_to_wstring("sandboxwindowsplatform_odin")
	window_class := windows.WNDCLASSW {
		style         = windows.CS_OWNDC | windows.CS_HREDRAW | windows.CS_VREDRAW,
		lpfnWndProc   = window_proc,
		hInstance     = windows.HINSTANCE(hinstance),
		hCursor       = windows.LoadCursorW(nil, ([^]u16)(windows._IDC_ARROW)),
		lpszClassName = class_name,
	}
	fmt.printf("window_class %v\n", window_class)

	if windows.RegisterClassW(&window_class) == 0 {
		msg := cstring("could not register class\n")
		windows.OutputDebugStringW(([^]u16)(&msg))
	}

	wsize := windows.RECT {
		right  = 1280,
		bottom = 720,
	}
	windows.AdjustWindowRect(&wsize, windows.WS_OVERLAPPEDWINDOW, false)
	fmt.printf("adjusted wndrect %v\n", wsize)

	window_title := windows.utf8_to_wstring("odin-lang hello winapi")
	window := windows.CreateWindowW(
		class_name,
		window_title,
		windows.WS_OVERLAPPEDWINDOW | windows.WS_VISIBLE,
		windows.CW_USEDEFAULT,
		windows.CW_USEDEFAULT,
		wsize.right - wsize.left,
		wsize.bottom - wsize.top,
		nil,
		nil,
		windows.HINSTANCE(hinstance),
		nil,
	)

	if window == nil {
		msg := cstring("could not create window\n")
		windows.OutputDebugStringW(([^]u16)(&msg))
		return
	}
	defer windows.DestroyWindow(window)

	backbuffer_width :: 1280 / 2
	backbuffer_height :: 720 / 2
	backbuffer_index: u32
	backbuffers: [2]Backbuffer
	resize_backbuffer(&backbuffers[0], backbuffer_width, backbuffer_height)
	resize_backbuffer(&backbuffers[1], backbuffer_width, backbuffer_height)
	defer windows.VirtualFree(backbuffers[0].memory, 0, windows.MEM_RELEASE)
	defer windows.VirtualFree(backbuffers[1].memory, 0, windows.MEM_RELEASE)
	fmt.printf("backbuffer[0]: %+v\n", backbuffers[0])
	fmt.printf("backbuffer[1]: %+v\n", backbuffers[1])

	game_update_hz := f32(30)
	target_seconds_per_frame := 1.0 / game_update_hz
	last_counter := get_clock_value()

	when DEBUG_DRAW_TIMINGS {
		debug_frame_timings: [256]f32
		debug_render_timings: [256]f32
		debug_highest_timing := f32(1)
	}

	input: [2]AppInput
	curr_input := &input[0]
	prev_input := &input[1]
	dc := windows.GetDC(window)
	defer windows.ReleaseDC(window, dc)
	for global_is_running {
		message: windows.MSG
		for windows.PeekMessageW(&message, window, 0, 0, windows.PM_REMOVE) {
			switch message.message {
			case windows.WM_QUIT:
				global_is_running = false
				msg := cstring("WM_QUIT\n")
				windows.OutputDebugStringW(([^]u16)(&msg))

			case windows.WM_SYSKEYDOWN, windows.WM_SYSKEYUP, windows.WM_KEYDOWN, windows.WM_KEYUP:
				msg := cstring("WM_SYS/KEY\n")
				windows.OutputDebugStringW(([^]u16)(&msg))
				key_code := uint(message.wParam)
				if key_code == windows.VK_ESCAPE {
					global_is_running = false
				}

				if translated_key, ok := input_key_translation[key_code]; ok {
					curr_input.keyboard[translated_key].down = ((message.lParam & (1 << 31)) == 0)
				}

			case:
				windows.TranslateMessage(&message)
				windows.DispatchMessageW(&message)
			}
		}

		mouse_point: windows.POINT
		windows.GetCursorPos(&mouse_point)
		windows.ScreenToClient(window, &mouse_point)
		curr_input.mouse_x = mouse_point.x / 2
		curr_input.mouse_y = mouse_point.y / 2

		curr_input.mouse_button[0].down = ((int(windows.GetKeyState(windows.VK_LBUTTON)) & (1 << 15)) != 0)
		curr_input.mouse_button[0].transition = (curr_input.mouse_button[0].down != prev_input.mouse_button[0].down)

		backbuffer := &backbuffers[backbuffer_index]
		backbuffer_index = (backbuffer_index + 1) % 2
		screen_buffer := Bitmap {
			buffer = ([^]u32)(backbuffer.memory)[0:backbuffer.pitch],
			width  = backbuffer.width,
			height = backbuffer.height,
		}

		when DEBUG_DRAW_TIMINGS {
			update_and_render_timing_start := get_clock_value()
		}
		app_update_and_render(&screen_buffer, curr_input)
		when DEBUG_DRAW_TIMINGS {
			update_and_render_timing_stop := get_clock_value()
		}

		curr_input, prev_input = prev_input, curr_input

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

		elapsed := get_seconds_elapsed(last_counter, get_clock_value())
		if elapsed < target_seconds_per_frame {
			if sleep_is_granular {
				sleep_ms := u32(1000 * (target_seconds_per_frame - elapsed))
				if sleep_ms > 0 {
					windows.Sleep(sleep_ms)
				}
			}

			for elapsed < target_seconds_per_frame {
				elapsed = get_seconds_elapsed(last_counter, get_clock_value())
			}
		} else {
			fmt.printf("missed sleep\n")
		}

		client_rect: windows.RECT
		windows.GetClientRect(window, &client_rect)
		dim_width := client_rect.right - client_rect.left
		dim_height := client_rect.bottom - client_rect.top
		blit_buffer_in_window(backbuffer, dc, dim_width, dim_height)

		when DEBUG_DRAW_TIMINGS {
			ms_per_frame := 1000.0 * elapsed
			frame_render_ms :=
				1000.0 * get_seconds_elapsed(update_and_render_timing_start, update_and_render_timing_stop)

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

		last_counter = get_clock_value()
	}
}
