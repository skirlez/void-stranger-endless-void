draw_placechanger_highlight()


var i_imageframe;
if animate {
	var iframes = sprite_get_number(sprite_index)
	var func = agi("scr_music_strobe_integer")
	if func == -1
		i_imageframe = image_index
	else
		i_imageframe = func(iframes)
}
else
	i_imageframe = 0
	

if global.pack_editor.node_instance_connecting == id
	ev_draw_pack_line(center_x, center_y, mouse_x, mouse_y)

var size = ((image_xscale + image_yscale) / 2) * 5
if unselectable
	draw_set_alpha(0.3)
ev_draw_cube(sprite_index, i_imageframe, x + shake_x_offset, y, size, spin_h, spin_v, optimize_opaque)
if unselectable
	draw_set_alpha(1)
	
if !in_menu {
	draw_set_color(c_white)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_font(global.ev_font)

	draw_text_shadow(x, y + 16, text)
}
