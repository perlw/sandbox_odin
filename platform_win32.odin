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

main :: proc() {
	fmt.println("Hellope!")

	hinstance := win32.get_module_handle_a(nil)
	fmt.printf("hinstance %x\n", hinstance)

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
	}
}
