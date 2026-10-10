draw_self()
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_font(global.ev_font)
draw_set_color(c_white)
var text;
if is_online_collision {
	text = "This pack already exists online:\n" 
			+ "\"" + old_nodeless_pack.name + "\"" + "\n"
			+ "Should the local copy share\n"
			+ "the same ID/save file?"
}
else
	text = "Would you like to update:\n" 
			+ "\"" + old_nodeless_pack.name + "\"" + "\n"
			+ "or to paste a new pack?"
draw_text_shadow(x, y - 20, text)