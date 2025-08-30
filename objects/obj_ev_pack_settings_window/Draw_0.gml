draw_self();


var minutes = floor(((current_time - global.pack_editor.save_timestamp) / 1000) / 60);
if minutes > 0 {
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_font(global.ev_font)
	draw_set_color(c_white)
	var noun = (minutes == 1) ? "minute" : "minutes";
	draw_text_shadow(105, 15, $"{minutes} {noun}\nsince last save")
}