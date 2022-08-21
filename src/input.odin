package main

// TODO: Add missing common keys + some basic umlauts.
AppInputKey :: enum u8 {
	Escape = 0,
	Num0,
	Num1,
	Num2,
	Num3,
	Num4,
	Num5,
	Num6,
	Num7,
	Num8,
	Num9,
}

AppButtonState :: struct {
	transition: bool,
	down:       bool,
}

AppInput :: struct {
	keyboard:     [255]AppButtonState,
	mouse_button: [5]AppButtonState,
	mouse_x:      i32,
	mouse_y:      i32,
}
