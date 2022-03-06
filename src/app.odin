package main

import "core:math"
import "core:math/linalg"

color_u32 :: #force_inline proc(r, g, b, a: u8) -> u32 {
	return (u32(a) << 24) + (u32(r) << 16) + (u32(g) << 8) + u32(b)
}

abs :: proc(a: i32) -> i32 {
	v := a >> 31
	return (a + v) ~ v
}

clamp :: proc(a, min, max: i32) -> i32 {
	t := (a < min ? min : a)
	return (t > max ? max : t)
}

draw_line :: proc(bitmap: ^Bitmap, x1, y1, x2, y2: i32, color: u32) {
	xx1 := clamp(x1, 0, i32(bitmap.width - 1))
	yy1 := clamp(y1, 0, i32(bitmap.height - 1))
	xx2 := clamp(x2, 0, i32(bitmap.width - 1))
	yy2 := clamp(y2, 0, i32(bitmap.height - 1))

	sx: i32 = (xx1 < xx2 ? 1 : -1)
	sy: i32 = (yy1 < yy2 ? 1 : -1)
	dx: i32 = abs(xx2 - xx1)
	dy: i32 = -abs(yy2 - yy1)

	x := xx1
	y := yy1
	e := dx + dy
	for {
		bitmap.buffer[(u32(y) * bitmap.width) + u32(x)] = color
		if x == xx2 && y == yy2 {
			break
		}

		e2 := e * 2
		if e2 >= dy {
			e += dy
			x += sx
		}
		if e2 <= dx {
			e += dx
			y += sy
		}
	}
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

draw_xor :: proc(bitmap: ^Bitmap) {
	@(static)
	offset: u32 = 0

	for y := u32(0); y < bitmap.height; y += 1 {
		i := y * bitmap.width
		for x: u32 = 0; x < bitmap.width; x += 1 {
			c := u8(((x + offset) ~ (y + offset)) % 256)
			bitmap.buffer[i + x] = color_u32(c, c, c, 0xFF)
		}
	}

	offset += 2
}

draw_slow_squircles :: proc(bitmap: ^Bitmap) {
	@(static)
	offset: u32 = 0
	@(static)
	scale: f32 = 256
	@(static)
	scale_speed: f32 = 0.3

	for y := u32(0); y < bitmap.height; y += 1 {
		i := y * bitmap.width
		for x: u32 = 0; x < bitmap.width; x += 1 {
			c := u8(128 + (math.sin(f32((x * x) + (y * y) + offset) / scale) * 127))
			bitmap.buffer[i + x] = color_u32(c, c, c, 0xFF)
		}
	}

	offset += 2
	scale -= scale_speed
	if scale <= 1.0 {
		scale = 1.0
		scale_speed = -scale_speed
	}
}

draw_fast_squircles :: proc(bitmap: ^Bitmap) {
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
		bitmap.buffer[i] = palette[(offset + int(p)) % 256]
	}

	offset = (offset + 1) % 256
}

draw_plasma :: proc(bitmap: ^Bitmap) {
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
		bitmap.buffer[i] = palette[(offset + int(p)) % 256]
	}

	/** Debug palette drawing */
	palette_start := int(bitmap.width * (bitmap.height - 11))
	for x := 0; x <= 256; x += 1 {
		bitmap.buffer[palette_start + x] = 0xFF000000
	}
	palette_start += int(bitmap.width)
	for y := 0; y < 10; y += 1 {
		y_offset := y * int(bitmap.width)
		for c, i in palette {
			bitmap.buffer[palette_start + y_offset + i] = c
		}
		bitmap.buffer[palette_start + y_offset + 256] = 0xFF000000
	}

	offset = (offset + 1) % 256
}

app_update_and_render :: proc(screen_buffer: ^Bitmap) {
	// draw_xor(screen_buffer)
	// draw_slow_squircles(screen_buffer)
	draw_fast_squircles(screen_buffer)
	// draw_plasma(screen_buffer)

	draw_line(screen_buffer, 220, 360, 420, 360, 0xFFFFFFFF)
	draw_line(screen_buffer, 320, 260, 320, 460, 0xFFFFFFFF)
	draw_line(screen_buffer, 220, 260, 420, 460, 0xFFFFFFFF)
	draw_line(screen_buffer, 220, 460, 420, 260, 0xFFFFFFFF)
	draw_line(screen_buffer, 220, 260, 420, 260, 0xFFFFFFFF)
	draw_line(screen_buffer, 220, 460, 420, 460, 0xFFFFFFFF)
	draw_line(screen_buffer, 220, 260, 220, 460, 0xFFFFFFFF)
	draw_line(screen_buffer, 420, 260, 420, 460, 0xFFFFFFFF)

	for α := 0; α < 180; α += 1 {
		θ := f32(α) / f32(math.DEG_PER_RAD)
		x := i32((math.cos(θ) * 100) + 0.5)
		y := -i32((math.sin(θ) * 100) + 0.5)
		draw_line(screen_buffer, 960 - x, 360 - y, 960 + x, 360 + y, 0xFFFFFFFF)
	}

	px: i32 = 50
	py: i32 = 0
	for α := 0; α <= 360; α += 45 {
		θ := f32(α) / f32(math.DEG_PER_RAD)
		x := i32((math.cos(θ) * 50) + 0.5)
		y := -i32((math.sin(θ) * 50) + 0.5)
		draw_line(screen_buffer, 640 + px, 360 + py, 640 + x, 360 + y, 0xFFFFFFFF)
		px = x
		py = y
	}
}
