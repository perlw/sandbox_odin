package main

Bitmap :: struct {
	buffer: []u32,
	width:  u32,
	height: u32,
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

draw_rect :: proc(bitmap: ^Bitmap, x1, y1, x2, y2: i32, color: u32) {
	xx1 := clamp(x1, 0, i32(bitmap.width - 1))
	yy1 := clamp(y1, 0, i32(bitmap.height - 1))
	xx2 := clamp(x2, 0, i32(bitmap.width - 1))
	yy2 := clamp(y2, 0, i32(bitmap.height - 1))

	for y in yy1 ..= yy2 {
		i := u32(y) * bitmap.width
		bitmap.buffer[i + u32(xx1)] = color
		bitmap.buffer[i + u32(xx2)] = color
	}
	iy1 := u32(yy1) * bitmap.width
	iy2 := u32(yy2) * bitmap.width
	for x in xx1 ..= xx2 {
		bitmap.buffer[iy1 + u32(x)] = color
		bitmap.buffer[iy2 + u32(x)] = color
	}
}

draw_bitmap :: proc(dest, src: ^Bitmap, dx, dy: i32) {
	draw_sub_bitmap(dest, src, dx, dy, 0, 0, src.width, src.height)
}

draw_sub_bitmap :: proc(dest, src: ^Bitmap, dx, dy: i32, sx1, sy1, sx2, sy2: u32) {
	dxx := u32(dx)
	dyy := u32(dy)
	/*
	// old bounds/rect checkfix, skipped for now
	off_x := u32(-dx if dx < 0 else 0)
	off_y := u32(-dy if dy < 0 else 0)
	sw := sx2 - sx1
	sh := sy2 - sy1
	end_x := sx2 if dxx + sw < dest.width else sx2 - (dxx + sw - dest.width)
	end_y := sy2 if dyy + sh < dest.height else sy2 - (dyy + sh - dest.height)
	for y in off_y ..< end_x {
		for x in off_x ..< end_y {
	*/

	sw := sx2 - sx1
	sh := sy2 - sy1
	for y in 0 ..< sh {
		si := (y + sy1) * src.width
		di := (y + dyy) * dest.width
		for x in 0 ..< sw {
			dest.buffer[di + (x + dxx)] = src.buffer[si + (x + sx1)]
		}
	}
}
