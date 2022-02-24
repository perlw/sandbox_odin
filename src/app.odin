package main

app_update_and_render :: proc(screen_buffer: ^Bitmap) {
	@(static)
	offset := u32(0)

	for y := u32(0); y < screen_buffer.height; y += 1 {
		i := y * screen_buffer.width
		for x := u32(0); x < screen_buffer.width; x += 1 {
			color := ((x + offset) ~ (y + offset)) % 256
			screen_buffer.buffer[i + x] = (0xff << 24) + (color << 16) + (color << 8) + color
		}
	}

	offset += 4
}
