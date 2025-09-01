draw_set_color(c_black)
for (var i = 0; i < array_length(circles); i++) {
	var circle = circles[i];
	var angle = circle.angle + add_angle
	
	draw_circle(x + circle.distance * dcos(angle), 
		y + circle.distance * -dsin(angle), circle.radius, false)
}

if timer <= 2 {
	draw_sprite(agi("spr_ev_placechanger_copy_shine"), 0, x, y)	
}