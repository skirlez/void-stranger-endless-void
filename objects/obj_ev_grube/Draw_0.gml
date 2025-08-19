spin_time_h += 0.45 + random_range(-0.05, 0.05)
spin_time_v += 0.38 + random_range(-0.05, 0.05)

var offset_x = 0

if death_timer != -1
	offset_x = sin(death_timer * 10) * (death_timer / 40)


var spin_h = (dsin(spin_time_h) + 1) / 2;
var spin_v = (dcos(spin_time_v) + 1) / 2;
ev_draw_cube(sprite_index, 0, phy_position_x + offset_x, phy_position_y, cube_size, spin_h + image_angle / 360, spin_v + image_angle / 360)
if death_timer != -1 {
	gpu_set_fog(true, c_white, 0, 1)	
	draw_set_alpha(min(1, death_timer / 140))
	ev_draw_cube(sprite_index, 0, phy_position_x + offset_x, phy_position_y, cube_size, spin_h + image_angle / 360, spin_v + image_angle / 360)
	gpu_set_fog(false, c_white, 0, 1)
	draw_set_alpha(1)	
}
if room == global.pack_editor_room {
	draw_set_color(c_white)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_font(global.ev_font)
	draw_text_shadow(x, y + 16, "Grube")
}
/*
for (var i = 0; i < array_length(position_history) - 1; i += 2) {
	var xpos = position_history[i]
	var ypos = position_history[i + 1]
	draw_text(x, y - 80 + i * 10, "(" + string(xpos) + ", " + string(ypos) + ")")
} 



