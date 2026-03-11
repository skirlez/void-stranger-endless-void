draw_set_color(c_white)
if global.erasing != -1 {
	if !surface_exists(erasing_surface)
		erasing_surface = surface_create(224, 144)
	surface_set_target(erasing_surface)
	draw_clear(c_black)
	draw_set_color(c_white)
	gpu_set_blendmode(bm_subtract);	
	var rand_x = irandom_range(-3, 3)
	var rand_y = irandom_range(-3, 3)
	var radius = sqrt(global.erasing) * 10;
	draw_circle(112 + rand_x, 72 + rand_y, radius, false)
	gpu_set_blendmode(bm_normal);
	
	draw_set_alpha(1 - min(1, (sqrt(global.erasing) * 10) / 350))
	draw_circle(112 + rand_x, 72 + rand_y, radius, false)
	draw_set_alpha(1)
	
	surface_reset_target()
	draw_surface(erasing_surface, 0, 0)
}

if (edit_transition != -1 || play_pack_transition_time != -1) {
	draw_clear(c_black)	
}

if (room == agi("rm_ev_menu")) {
	draw_set_color(c_white)
	draw_set_font(global.ev_font)
	draw_set_halign(fa_left)
	draw_set_valign(fa_middle)
	
	
	if global.there_is_a_newer_version
		draw_text_transformed(6, 72 + 62, "THERE IS A NEWER VERSION!!!\n" + $"You are on {global.ev_version}, latest is {global.newest_version}", 0.5, 0.5, 0)
	else
		draw_text_transformed(6, 72 + 65, global.ev_version, 0.5, 0.5, 0)
}
else if (room == global.startup_room) {
	draw_set_color(c_white)
	draw_set_font(global.ev_font)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text_transformed(112, 72, $"Communicating with server...\nTasks left: {startup_actions_count}", 1, 1, 0)
}

