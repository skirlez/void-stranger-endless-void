draw_self()
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_font(global.ev_font)
draw_set_color(c_white)

draw_text_shadow(x, y - 25, "Would you like to update:\n" + old_pack.name + "\nor to paste a new pack?")