if (array_length(levels) == 0) {
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_color(c_white)
	draw_text_shadow(room_width / 2, room_height - 20, "No levels from this source...", c_black)
}
draw_clear(c_gray)
draw_sprite(agi("spr_ev_ls_border"), 0, 0, 0)

var page_string;
var page_max = (array_length(filtered_levels) - 1) div 6;
var page = global.level_start;
page_string = string(page + 1) + "/" + string(page_max + 1);
		
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
draw_set_font(global.ev_font)
		
draw_text_shadow(194, 95 - 16, page_string, c_black)