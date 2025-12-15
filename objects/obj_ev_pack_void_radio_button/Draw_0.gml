
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
var s = 24; 
// we're using a surface because it looks better for rotation with a shadow
// (and there was a bug with draw_text_transformed specifically on VS' runtime version?)
if !surface_exists(surface_number) {
	surface_number = surface_create(s, s)
}
surface_set_target(surface_number)
draw_clear_alpha(c_black, 0)

var txt;
if music_index == -1
	txt = string_repeat(".", (global.editor_time div 4) % 3 + 1)
else
	txt = string(music_index)
draw_shadow_generic(s div 2, s div 2, function (_x, _y, txt) {
	var top;
	var bottom;
	if draw_get_color() == c_black {
		top = c_black
		bottom = c_black
	}
	else {
		/*
		var song_progress;
	
		var song_length = ev_get_real_track_end(global.music_file)
		if song_length == 0
			song_progress = 1;
		else
			song_progress = 
				(audio_sound_get_track_position(global.music_inst) - ev_get_real_track_start(global.music_file))
				/ (song_length - ev_get_real_track_start(global.music_file))
		*/
		// there was supposed to be an effect here...
		// where the number would change color, from the bottom up, depending on how close the song is to ending
		// but i couldn't get it working quite right using this function
		top = c_white
		bottom = c_white
	}
		
	draw_text_color(_x, _y, txt, top, top, bottom, bottom, 1)
}, txt);
surface_reset_target()


var angle_offset_correction_x = sqrt(2) * (s div 2) * dcos(135 + number_angle) * number_size;
var angle_offset_correction_y = sqrt(2) * (s div 2) * -dsin(135 + number_angle) * number_size;
draw_surface_ext(surface_number, 
	x + (number_x + 18 + angle_offset_correction_x) * ratio_x,
	y + (number_y + angle_offset_correction_y) * ratio_y,
	base_scale_x * ratio_x * number_size,
	base_scale_y * ratio_y * number_size,
	number_angle,
	c_white, 1)

if (global.void_radio_on) {
	gpu_set_fog(true, c_white, 0, 1)
	var increase = (1.1 + (dsin(global.editor_time) + 1) / 16);

	ev_draw_cube(sprite_index, 0, x, y, image_xscale * cube_scale_multiplier * increase, spin_h, spin_v)
	gpu_set_fog(false, c_white, 0, 1)
}
ev_draw_cube(sprite_index, 0, x, y, image_xscale * cube_scale_multiplier, spin_h, spin_v)

