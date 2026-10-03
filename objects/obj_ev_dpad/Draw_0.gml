if ev_mouse_held() && ev_is_mouse_on_me()
	struct = calculate_offset_direction()
else
	struct = empty_offset_struct

var scale = image_xscale * 8
var spin_h = -struct.offset_x / 16
var spin_v = -struct.offset_y / 16

// we want the dpad to tilt but not stray from the center
var draw_offset_x = spin_h * 35
var draw_offset_y = spin_v * 35


ev_draw_cube_multisprite(sprites_array, indices_array, x + draw_offset_x, y + draw_offset_y, scale, spin_h, spin_v, true)
	
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_font(global.ev_font)
draw_set_color(c_white)
draw_text_shadow(x, y + 16, string(offset_x) + ", " + string(offset_y));