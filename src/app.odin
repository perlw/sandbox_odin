package main

import "core:math"
import "core:math/linalg"

color_u32 :: #force_inline proc(r, g, b, a: u8) -> u32 {
	return (u32(a) << 24) + (u32(r) << 16) + (u32(g) << 8) + u32(b)
}

// h: 0-360, s: 0-1, v: 0-1
rgb_to_hsv :: proc(h: u32, s: f32, v: f32) -> u32 {
	c := s * v
	x := c * (1 - linalg.abs(math.mod(f32(h) / 60, 2) - 1))
	m := v - c

	r1, g1, b1: f32
	if h >= 0 && h < 60 {
		r1, g1, b1 = c, x, 0
	} else if h >= 60 && h < 120 {
		r1, g1, b1 = x, c, 0
	} else if h >= 120 && h < 180 {
		r1, g1, b1 = 0, c, x
	} else if h >= 180 && h < 240 {
		r1, g1, b1 = 0, x, c
	} else if h >= 240 && h < 300 {
		r1, g1, b1 = x, 0, c
	} else {
		r1, g1, b1 = c, 0, x
	}

	r := u8((r1 + m) * 255)
	g := u8((g1 + m) * 255)
	b := u8((b1 + m) * 255)

	return color_u32(r, g, b, 0xFF)
}

draw_xor :: proc(screen_buffer: ^Bitmap) {
	@(static)
	offset: u32 = 0

	for y := u32(0); y < screen_buffer.height; y += 1 {
		i := y * screen_buffer.width
		for x: u32 = 0; x < screen_buffer.width; x += 1 {
			c := u8(((x + offset) ~ (y + offset)) % 256)
			screen_buffer.buffer[i + x] = color_u32(c, c, c, 0xFF)
		}
	}

	offset += 2
}

draw_slow_squircles :: proc(screen_buffer: ^Bitmap) {
	@(static)
	offset: u32 = 0
	@(static)
	scale: f32 = 256
	@(static)
	scale_speed: f32 = 0.3

	for y := u32(0); y < screen_buffer.height; y += 1 {
		i := y * screen_buffer.width
		for x: u32 = 0; x < screen_buffer.width; x += 1 {
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

draw_fast_squircles :: proc(screen_buffer: ^Bitmap) {
	@(static)
	offset := 0
	@(static)
	scale: f32 = 512
	@(static)
	palette: [256]u32
	if palette[0] == 0x0 {
		for i := 0; i < 256; i += 1 {
			palette[i] = rgb_to_hsv(u32((f32(i) * 1.4) + 0.5), 1, 1)
		}
	}
	@(static)
	buffer: [1280 * 720]u8
	if buffer[0] == 0 {
		for y := u32(0); y < 720; y += 1 {
			i := y * 1280
			for x: u32 = 0; x < 1280; x += 1 {
				c := u8(128 + (math.sin(f32((x * x) + (y * y)) / scale) * 127))
				buffer[i + x] = c
			}
		}
	}

	for p, i in buffer {
		screen_buffer.buffer[i] = palette[(offset + int(p)) % 256]
	}

	offset = (offset + 1) % 256
}

draw_plasma :: proc(screen_buffer: ^Bitmap) {
	@(static)
	offset := 0
	@(static)
	palette: [256]u32
	if palette[0] == 0x0 {
		for i := 0; i < 256; i += 1 {
			palette[i] = rgb_to_hsv(u32((f32(i) * 1.4) + 0.5), 1, 1)
		}
	}
	@(static)
	buffer: [1280 * 720]u8
	if buffer[0] == 0 {
		for y := u32(0); y < 720; y += 1 {
			i := y * 1280
			for x: u32 = 0; x < 1280; x += 1 {
				c := u8((128 + (math.sin(f32(x) / 16) * 128) + 128 + (math.sin(f32(y) / 16) * 128)) / 2)
				buffer[i + x] = c
			}
		}
	}

	for p, i in buffer {
		screen_buffer.buffer[i] = palette[(offset + int(p)) % 256]
	}

	/** Debug palette drawing */
	palette_start := int(screen_buffer.width * (screen_buffer.height - 11))
	for x := 0; x <= 256; x += 1 {
		screen_buffer.buffer[palette_start + x] = 0xFF000000
	}
	palette_start += int(screen_buffer.width)
	for y := 0; y < 10; y += 1 {
		y_offset := y * int(screen_buffer.width)
		for c, i in palette {
			screen_buffer.buffer[palette_start + y_offset + i] = c
		}
		screen_buffer.buffer[palette_start + y_offset + 256] = 0xFF000000
	}

	offset = (offset + 1) % 256
}

app_update_and_render :: proc(screen_buffer: ^Bitmap) {
	// draw_xor(screen_buffer)
	// draw_slow_squircles(screen_buffer)
	draw_fast_squircles(screen_buffer)
	// draw_plasma(screen_buffer)
}
