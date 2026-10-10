
draw_self()

draw_sprite(spr_monogram_bg, 0, center_x, center_y)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)

draw_text_shadow(center_x, center_y - 54, string(draw_monogram.width))
draw_text_shadow(center_x - 74, center_y, string(draw_monogram.height))

