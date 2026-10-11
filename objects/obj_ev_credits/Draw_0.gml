
if grube_mode {
	draw_set_font(global.ev_font)
	draw_set_halign(fa_center)
	draw_set_valign(fa_top)
	var highest_str = string(highest_stack) + "\n"
	if potential_new_highest_stack != 0 {
		highest_str += "CHECKING STABILITY\n"
		repeat ((global.editor_time / 3) % 3 + 1) {
			highest_str += "."
		}	
	}
	
	var camera_y = camera_get_view_y(view_camera[0]);
	draw_set_color(c_black)
	ev_draw_rectangle(20, camera_y + 5, 25, camera_y + 30, false)
	draw_set_color(c_white)
	var elevation = 1 - camera_y / 5552
	
	var slider_height = 5;
	var slider_y = lerp(30 - slider_height, 5, elevation)

	
	ev_draw_rectangle(20, camera_y + slider_y, 25, camera_y + slider_y + slider_height, false)

	var txt = "STACK THE GRUBES\nSTACK: " + string(max_stack) + "\nHIGHEST: " + highest_str;
	var size = 0.5
	
	var gy = camera_y + 5;
	
	draw_set_color(c_black)
	draw_text_transformed(112 + size, gy, txt, size, size, 0)
	draw_text_transformed(112 - size, gy, txt, size, size, 0)
	draw_text_transformed(112, gy + size, txt, size, size, 0)
	draw_text_transformed(112, gy - size, txt, size, size, 0)

	draw_set_color(c_white)
	draw_text_transformed(112, gy, txt, size, size, 0)


	draw_sprite(agi("spr_ev_tools"), 0, mouse_x, mouse_y)

	exit
}

if !surface_exists(credits_surface) {
	credits_surface = surface_create(credits_surface_width, 144)	
}
surface_set_target(credits_surface)
draw_clear_alpha(c_black, 0);


draw_set_font(global.ev_font)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)


var draw_x = 4;
var draw_y = 2;
for (var i = 0; i < array_length(current_page); i++) {
	var entry = current_page[i];
	if entry.time_until_active <= 0
		draw_y = entry.draw(draw_x, draw_y);
}
surface_reset_target();

var surface_y = 5552
draw_surface(credits_surface, 0, surface_y)
ev_draw_rectangle(credits_surface_width, surface_y, credits_surface_width + 2, surface_y + 144, false);


var page = current_page_index
var max_pages = array_length(credits)
var page_string = string(page + 1) + "/" + string(max_pages)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text_shadow(200, surface_y + 88 - 16, page_string)
