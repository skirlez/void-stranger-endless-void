function draw_text_shadow(_x, _y, txt, shadow_color = c_black) {
	var save = draw_get_color()
	draw_set_color(shadow_color)
	draw_text(_x + 1, _y, txt)
	draw_text(_x - 1, _y, txt)
	draw_text(_x, _y + 1, txt)
	draw_text(_x, _y - 1, txt)
	draw_set_color(save)
	draw_text(_x, _y, txt)
}
function draw_shadow_generic(_x, _y, draw_function, other_params = noone, shadow_color = c_black, unit = 1) {
	var save = draw_get_color()
	draw_set_color(shadow_color)
	draw_function(_x + unit, _y, other_params)
	draw_function(_x - unit, _y, other_params)
	draw_function(_x, _y + unit, other_params)
	draw_function(_x, _y - unit, other_params)
	draw_set_color(save)
	draw_function(_x, _y, other_params)
}