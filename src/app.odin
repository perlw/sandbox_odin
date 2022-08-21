package main

import "core:math"
import "core:math/linalg"
import "core:mem"
import "core:os"
import "core:c"

import "core:fmt"
import stbtt "vendor:stb/truetype"
import mu "vendor:microui"

DEBUG_DRAW_UI_CALLS :: #config(DEBUG_DRAW_UI_CALLS, false)

color_u32 :: proc {
	color_u8_to_u32,
	color_mu_color_to_u32,
}

color_u8_to_u32 :: #force_inline proc(r, g, b, a: u8) -> u32 {
	return (u32(a) << 24) + (u32(r) << 16) + (u32(g) << 8) + u32(b)
}

color_mu_color_to_u32 :: #force_inline proc(c: mu.Color) -> u32 {
	return (u32(c.a) << 24) + (u32(c.r) << 16) + (u32(c.g) << 8) + u32(c.b)
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
	return t > max ? max : t
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

	i: u32
	for y: u32; y < bitmap.height; y += 1 {
		for x: u32; x < bitmap.width; x += 1 {
			c := u8(((x + offset) ~ (y + offset)) % 256)
			bitmap.buffer[i] = color_u32(c, c, c, 0xFF)
			i += 1
		}
	}

	offset += 2
}

Fixed_Width :: 1280 / 2
Fixed_Height :: 720 / 2

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
		i: u32
		for y: u32; y < Fixed_Height; y += 1 {
			for x: u32; x < Fixed_Width; x += 1 {
				c := u8(128 + (math.sin(f32((x * x) + (y * y)) / scale) * 127))
				buffer[i] = c
				i += 1
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
		i: u32
		for y: u32; y < Fixed_Height; y += 1 {
			for x: u32; x < Fixed_Width; x += 1 {
				c := u8((128 + (math.sin(f32(x) / 16) * 128) + 128 + (math.sin(f32(y) / 16) * 128)) / 2)
				buffer[i] = c
				i += 1
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

// TODO: Basic 24-bit .bmp-support. (can/should use stb libs in the future)
// TODO: Basic bitmap functions. (sub-copy, alpha, etc)
// TODO: Advanced bitmap functions. (line, rectangle, triangle, filled, etc)
// TODO: Controller support, win/lin.
// TODO: "Piano" scene. (after audio)

scene_funcs := []proc(_: ^Bitmap){draw_xor, draw_fast_circles, draw_plasma, draw_line_tests}

FONT_HEIGHT :: 20
font_bitmap: Bitmap
glyph_data: [96]stbtt.bakedchar
ctx: mu.Context
@(init)
init_mu :: proc() {
	{
		when ODIN_OS == .Windows {
			data, ok := os.read_entire_file_from_filename("C:\\Windows\\Fonts\\arial.ttf")
		}
		when ODIN_OS == .Linux {
			data, ok := os.read_entire_file_from_filename("/usr/share/fonts/TTF/OpenSans-Regular.ttf")
		}
		if !ok {
			fmt.println("fail reading font")
			return
		}

		font: stbtt.fontinfo
		stbtt.InitFont(&font, &data[0], stbtt.GetFontOffsetForIndex(&data[0], 0))
		temp_bitmap: [256 * 256]byte
		stbtt.BakeFontBitmap(&data[0], 0, FONT_HEIGHT, &temp_bitmap[0], 256, 256, 32, 96, &glyph_data[0])

		fmt.printf("%+v\n", glyph_data)

		font_bitmap.buffer = make([]u32, 256 * 256)
		font_bitmap.width = 256
		font_bitmap.height = 256
		for i in 0 ..< len(temp_bitmap) {
			font_bitmap.buffer[i] = color_u32(temp_bitmap[i], 0, 0, 255)
		}
	}

	mu.init(&ctx)
	ctx.text_width = proc(font: mu.Font, str: string) -> i32 {
		// fmt.printf("checking text_width: %s\n", str)
		width: i32
		for r in str {
			gd := &glyph_data[r - 32]
			width += i32(gd.xadvance + 0.5)
		}
		return width
	}
	ctx.text_height = proc(font: mu.Font) -> i32 {
		return FONT_HEIGHT
	}
}

// TODO: Text drawing.
// TODO: VirtualAlloc'ed/shm memory, hooked into Odin's context.
app_update_and_render :: proc(screen_buffer: ^Bitmap, input: ^AppInput) {
	@(static)
	scene_num := 0
	@(static)
	mouse_x: i32
	@(static)
	mouse_y: i32

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
	}

	scene_funcs[scene_num](screen_buffer)

	draw_bitmap(screen_buffer, &font_bitmap, 400, 100)

	mx: i32
	my: i32
	if input.mouse_x > 0 && input.mouse_x < i32(screen_buffer.width) - 10 {
		mx = input.mouse_x
	}
	if input.mouse_y > 0 && input.mouse_y < i32(screen_buffer.height) - 10 {
		my = input.mouse_y
	}
	if mx != mouse_x || my != mouse_y {
		mu.input_mouse_move(&ctx, mx, my)
	}

	if input.mouse_button[0].transition {
		if input.mouse_button[0].down {
			mu.input_mouse_down(&ctx, mx, my, .LEFT)
		} else {
			mu.input_mouse_up(&ctx, mx, my, .LEFT)
		}
	}
	mouse_x, mouse_y = mx, my


	/*
  input_scroll :: proc(ctx: ^Context, x, y: i32)
  input_key_down :: proc(ctx: ^Context, key: Key)
  input_key_up :: proc(ctx: ^Context, key: Key)
  input_text :: proc(ctx: ^Context, text: string)
  */

	draw_rect(
		screen_buffer,
		mouse_x,
		mouse_y,
		mouse_x + 10,
		mouse_y + 10,
		0xFFFF00FF if input.mouse_button[0].down else 0xFFFF0000,
	)

	mu.begin(&ctx)
	if mu.begin_window(&ctx, "Test Window", {x = 10, y = 10, w = 200, h = 200}) {
		mu.label(&ctx, "Test label")
		mu.button(&ctx, "Button!")
		mu.end_window(&ctx)
	}
	if mu.begin_window(&ctx, "Test Slider", {x = 100, y = 20, w = 200, h = 200}) {
		value := f32(650)
		mu.slider(&ctx, &value, 42, 1337, 10)
		mu.end_window(&ctx)
	}
	mu.end(&ctx)


	clip := [?]i32{0, 0, i32(screen_buffer.width), i32(screen_buffer.height)}
	cmd: ^mu.Command = nil
	for mu.next_command(&ctx, &cmd) {
		switch c in cmd.variant {
		case ^mu.Command_Jump:
			fmt.println("Command_Jump")

		case ^mu.Command_Text:
			x := f32(c.pos[0])
			y := f32(c.pos[1] + 16)
			for r in c.str {
				quad: stbtt.aligned_quad
				stbtt.GetBakedQuad(&glyph_data[0], 256, 256, i32(r - 32), &x, &y, &quad, true)

				if i32(quad.x0) < clip[0] || i32(quad.x1) > clip[2] {
					continue
				}
				if i32(quad.y0) < clip[1] || i32(quad.y1) > clip[3] {
					continue
				}

				sx1 := u32(quad.s0 * 256.0)
				sy1 := u32(quad.t0 * 256.0)
				sx2 := u32(quad.s1 * 256.0)
				sy2 := u32(quad.t1 * 256.0)
				// fmt.printf("%c #%+v -> %d, %d : %d, %d\n", r, quad, sx1, sy1, sx2, sy2)
				draw_sub_bitmap(screen_buffer, &font_bitmap, i32(quad.x0), i32(quad.y0), sx1, sy1, sx2, sy2)

				/*
        when DEBUG_DRAW_UI_CALLS {
          draw_rect(
            screen_buffer,
            i32(quad.x0 + 0.5),
            i32(quad.y0 + 0.5),
            i32(quad.x1 + 0.5),
            i32(quad.y1 + 0.5),
            0xFFFF00FF,
          )
        }
        */
			}

		case ^mu.Command_Rect:
			x1, x2 := c.rect.x, c.rect.x + c.rect.w
			y1, y2 := c.rect.y, c.rect.y + c.rect.h
			for y in y1 ..< y2 {
				if y < clip[1] || y >= clip[3] {
					continue
				}
				for x in x1 ..< x2 {
					if x < clip[0] || x >= clip[2] {
						continue
					}
					screen_buffer.buffer[(y * i32(screen_buffer.width)) + x] = color_u32(c.color)
				}
			}
			when DEBUG_DRAW_UI_CALLS {
				draw_rect(screen_buffer, x1, y1, x2, y2, 0xFFFF0000)
			}

		case ^mu.Command_Icon:
			when DEBUG_DRAW_UI_CALLS {
				x1, x2 := c.rect.x, c.rect.x + c.rect.w
				y1, y2 := c.rect.y, c.rect.y + c.rect.h
				draw_rect(screen_buffer, x1, y1, x2, y2, 0xFF0000FF)
			}

		case ^mu.Command_Clip:
			clip[0] = c.rect.x
			clip[1] = c.rect.y
			clip[2] = c.rect.x + c.rect.w
			clip[3] = c.rect.y + c.rect.h
			when DEBUG_DRAW_UI_CALLS {
				draw_rect(screen_buffer, clip[0], clip[1], clip[2], clip[3], 0xFFFFAA00)
			}
		}
	}
}

glyph :: struct {
	bitmap: [^]byte,
	width:  int,
	height: int,
}

@(init)
test_stbtt :: proc() {
	when ODIN_OS == .Windows {
		data, ok := os.read_entire_file_from_filename("C:\\Windows\\Fonts\\arialbd.ttf")
	}
	when ODIN_OS == .Linux {
		data, ok := os.read_entire_file_from_filename("/usr/share/fonts/TTF/OpenSans-Regular.ttf")
	}
	if !ok {
		fmt.println("fail reading font")
		return
	}

	font: stbtt.fontinfo
	stbtt.InitFont(&font, &data[0], stbtt.GetFontOffsetForIndex(&data[0], 0))

	max_h: int
	msg := "Hello stb_truetype!"
	glyphs := make(map[rune]glyph)
	defer delete(glyphs)
	for r in msg {
		if !(r in glyphs) {
			w, h: c.int
			bitmap := stbtt.GetCodepointBitmap(&font, 0, stbtt.ScaleForPixelHeight(&font, 16), r, &w, &h, nil, nil)
			glyphs[r] = {
				bitmap = bitmap,
				width  = int(w),
				height = int(h),
			}
			if int(h) > max_h {
				max_h = int(h)
			}
		}
	}
	defer {
		for r in glyphs {
			defer stbtt.FreeBitmap(glyphs[r].bitmap, nil)
		}
	}

	fmt.printf("%+v\nmax_h %d\n", glyphs, max_h)

	chars := [?]rune{' ', '.', ':', 'i', 'o', 'V', 'M', '@'}
	for y in 0 ..< max_h {
		for r in msg {
			g := glyphs[r]

			if g.bitmap == nil {
				for in 0 ..< 4 {
					fmt.printf(" ")
				}
				fmt.printf(" ")
				continue
			}

			offset := max_h - g.height
			if y < offset || y >= max_h - 1 {
				for x in 0 ..< g.width {
					fmt.printf(" ")
				}
				fmt.printf(" ")
				continue
			}

			i := (y - offset) * g.width
			for x in 0 ..< g.width {
				fmt.printf("%c", chars[g.bitmap[i + x] >> 5])
			}
			fmt.printf(" ")
		}
		fmt.println()
	}
	fmt.println()
}
