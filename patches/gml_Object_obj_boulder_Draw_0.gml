// Draw Tis statue projection

// TARGET: TAIL
if b_form == 10 && (o_move_x != 0 || o_move_y != 0) {
	draw_sprite_ext(sprite_index, image_speed, x + o_move_x, y + o_move_y, image_xscale, image_yscale,
		image_angle, image_blend, (dsin(global.editor_time * 3) / 4) + 0.5)

}