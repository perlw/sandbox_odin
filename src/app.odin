package main

import "core:math"

color_u32 :: #force_inline proc(r, g, b, a: u8) -> u32 {
	return (u32(a) << 24) + (u32(r) << 16) + (u32(g) << 8) + u32(b)
}

draw_xor :: proc(screen_buffer: ^Bitmap) {
	@(static)
	offset : u32 = 0

	for y := u32(0); y < screen_buffer.height; y += 1 {
		i := y * screen_buffer.width
		for x : u32 = 0; x < screen_buffer.width; x += 1 {
			c := u8(((x + offset) ~ (y + offset)) % 256)
			screen_buffer.buffer[i + x] = color_u32(c, c, c, 0xFF)
		}
	}

	offset += 2
}

draw_squircles :: proc(screen_buffer: ^Bitmap) {
	@(static)
	offset : u32 = 0
	@(static)
	scale : f32 = 256
	@(static)
	scale_speed : f32 = 0.3

	for y := u32(0); y < screen_buffer.height; y += 1 {
		i := y * screen_buffer.width
		for x : u32 = 0; x < screen_buffer.width; x += 1 {
			c := u8(128 + (math.sin(f32((x * x) + (y * y) + offset) / scale) * 127))
			screen_buffer.buffer[i + x] = color_u32(c, c, c, 0xFF)
		}
	}

	offset += 2
	scale -= scale_speed
	if scale <= 1.0 {
		scale = 1.0
		scale_speed = -scale_speed
	}
}

draw_plasma :: proc(screen_buffer: ^Bitmap) {
	@(static)
	offset := 0
	@(static)
	palette : [256]u32
	if palette[0] == 0x0 {
		for i := 0; i < 128; i += 1 {
			c := color_u32(u8(i), u8(i), u8(i), 0xFF)
			palette[i] = c
			palette[255 - i] = c
		}
	}
	@(static)
	buffer : [1280 * 720]u8
	if buffer[0] == 0 {
		for y := u32(0); y < 720; y += 1 {
			i := y * 1280
			for x : u32 = 0; x < 1280; x += 1 {
				c := u8((
					128 + (math.sin(f32(x) / 16) * 128) +
					128 + (math.sin(f32(y) / 16) * 128)
				) / 2)
				buffer[i + x] = c
			}
		}
	}

	for _, i in buffer {
		screen_buffer.buffer[i] = palette[(offset + int(buffer[i])) % 256]
	}

	offset = (offset + 1) % 256
}

app_update_and_render :: proc(screen_buffer: ^Bitmap) {
	// draw_xor(screen_buffer)
	// draw_squircles(screen_buffer)
	draw_plasma(screen_buffer)
}
