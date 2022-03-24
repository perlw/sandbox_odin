package main

import "core:math"
import "core:math/linalg"
import "core:mem"

color_u32 :: #force_inline proc(r, g, b, a: u8) -> u32 {
	return (u32(a) << 24) + (u32(r) << 16) + (u32(g) << 8) + u32(b)
}

round_i32 :: #force_inline proc(v: f32) -> i32 {
	return i32(v + 0.5)
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

draw_slow_circles :: proc(bitmap: ^Bitmap) {
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

Fixed_Width :: 1280
Fixed_Height :: 720

draw_fast_circles :: proc(bitmap: ^Bitmap) {
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
	buffer: [Fixed_Width * Fixed_Height]u8
	if buffer[0] == 0 {
		for y := u32(0); y < Fixed_Height; y += 1 {
			i := y * Fixed_Width
			for x: u32 = 0; x < Fixed_Width; x += 1 {
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
	buffer: [Fixed_Width * Fixed_Height]u8
	if buffer[0] == 0 {
		for y := u32(0); y < Fixed_Height; y += 1 {
			i := y * Fixed_Width
			for x: u32 = 0; x < Fixed_Width; x += 1 {
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

draw_line_tests :: proc(screen_buffer: ^Bitmap) {
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

TrackPiece :: struct {
	curvature: f32,
	length:    f32,
}

// Credit to:
//  Code-It-Yourself! Retro Arcade Racing Game - Programming from Scratch (Quick and Simple C++)
//  https://www.youtube.com/watch?v=KkMZI5Jbf18
draw_olc_race :: proc(screen_buffer: ^Bitmap) {
	@(static)
	pos: f32
	@(static)
	track_curve: f32
	@(static)
	track: []TrackPiece = {
		{0, 10},
		{0, 200},
		{1, 200},
		{0, 400},
		{-1, 100},
		{0, 200},
		{-1, 200},
		{1, 200},
		{0, 200},
		{0.2, 500},
		{0, 200},
	}
	@(static)
	track_distance: f32
	if track_distance <= 0 {
		for section in track {
			track_distance += section.length
		}
	}

	if pos >= track_distance {
		pos -= track_distance
	}

	offset: f32 = 0
	track_section := 0
	for track_section < len(track) && offset <= pos {
		offset += track[track_section].length
		track_section += 1
	}
	target_curve := track[track_section - 1].curvature
	track_curve += (target_curve - track_curve) * 0.0333 // ~30fps

	mem.zero_slice(screen_buffer.buffer)

	horizon := i32(screen_buffer.height / 2)
	// Sky
	for y: i32 = 0; y < horizon; y += 1 {
		color: u32 = (y < horizon / 2 ? 0xFF000033 : 0xFF000066)
		for x: i32 = 0; x < i32(screen_buffer.width); x += 1 {
			screen_buffer.buffer[(y * i32(screen_buffer.width)) + x] = color
		}
	}
	for x: i32 = 0; x < i32(screen_buffer.width); x += 1 {
		hill_height := abs(i32(math.sin((f32(x) * 0.0025) + track_curve) * 64))
		for y: i32 = horizon - hill_height; y < i32(screen_buffer.height); y += 1 {
			screen_buffer.buffer[(y * i32(screen_buffer.width)) + x] = 0xFF003300
		}
	}

	// Track
	for y: i32 = 0; y < horizon; y += 1 {
		perspective := f32(y) / f32(horizon)
		mid_point: f32 = 0.5 + (track_curve * math.pow(1 - perspective, 3))

		road_width := 0.1 + (perspective * 0.8)
		clip_width := road_width * 0.15
		road_width *= 0.5

		left_grass := round_i32((mid_point - road_width - clip_width) * f32(screen_buffer.width))
		left_clip := round_i32((mid_point - road_width) * f32(screen_buffer.width))
		right_clip := round_i32((mid_point + road_width) * f32(screen_buffer.width))
		right_grass := round_i32((mid_point + road_width + clip_width) * f32(screen_buffer.width))

		grass_color: u32 = (math.sin(20 * math.pow(1 - perspective, 3) + (pos * 0.1)) >
		0 ? 0xFF00AA00 : 0xFF006600)
		clip_color: u32 = (math.sin(80 * math.pow(1 - perspective, 2) + pos) >
		0 ? 0xFFAA0000 : 0xFFFFFFFF)

		i := (horizon + y) * i32(screen_buffer.width)
		for x: i32 = 0; x < i32(screen_buffer.width); x += 1 {
			if x >= 0 && x < left_grass {
				screen_buffer.buffer[i + x] = grass_color
			}
			if x >= left_grass && x < left_clip {
				screen_buffer.buffer[i + x] = clip_color
			}
			if x >= left_clip && x < right_clip {
				screen_buffer.buffer[i + x] = 0xFFAAAAAA
			}
			if x >= right_clip && x < right_grass {
				screen_buffer.buffer[i + x] = clip_color
			}
			if x >= right_grass {
				screen_buffer.buffer[i + x] = grass_color
			}
		}
	}

	pos += 5
}

// Credit to:
//  http://www.extentofthejam.com/pseudo/
//  https://codeincomplete.com/articles/javascript-racer-v1-straight/
draw_joe_race :: proc(screen_buffer: ^Bitmap) {
}

// Credit to:
//  https://github.com/s-macke/VoxelSpace
draw_voxel_space :: proc(screen_buffer: ^Bitmap) {
}

// TODO: "Piano" scene.
// TODO: Basic 24-bit .bmp-support. (can/should use stb libs in the future)
// TODO: Advanced bitmap functions.
// TODO: Controller support, win/lin.

scene_funcs := []proc(_: ^Bitmap){
	draw_xor,
	draw_slow_circles,
	draw_fast_circles,
	draw_plasma,
	draw_line_tests,
	draw_olc_race,
	draw_joe_race,
	draw_voxel_space,
}

// TODO: Text drawing.
// TODO: VirtualAlloc'ed/shm memory, hooked into Odin's context.
app_update_and_render :: proc(screen_buffer: ^Bitmap, input: ^AppInput) {
	@(static)
	scene_num := 0

	if input.keyboard[AppInputKey.Num1].down {
		scene_num = 0
		mem.zero_slice(screen_buffer.buffer)
	} else if input.keyboard[AppInputKey.Num2].down {
		scene_num = 1
		mem.zero_slice(screen_buffer.buffer)
	} else if input.keyboard[AppInputKey.Num3].down {
		scene_num = 2
		mem.zero_slice(screen_buffer.buffer)
	} else if input.keyboard[AppInputKey.Num4].down {
		scene_num = 3
		mem.zero_slice(screen_buffer.buffer)
	} else if input.keyboard[AppInputKey.Num5].down {
		scene_num = 4
		mem.zero_slice(screen_buffer.buffer)
	} else if input.keyboard[AppInputKey.Num6].down {
		scene_num = 5
		mem.zero_slice(screen_buffer.buffer)
	} else if input.keyboard[AppInputKey.Num7].down {
		scene_num = 6
		mem.zero_slice(screen_buffer.buffer)
	} else if input.keyboard[AppInputKey.Num8].down {
		scene_num = 7
		mem.zero_slice(screen_buffer.buffer)
	}

	scene_funcs[scene_num](screen_buffer)
}
