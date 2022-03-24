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
	transitions: int,
	down:        bool,
}

AppInput :: struct {
	keyboard: [255]AppButtonState,
}
