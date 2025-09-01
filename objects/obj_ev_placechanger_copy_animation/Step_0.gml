timer--;
if timer == 0 {
	instance_destroy(id)
	exit	
}

if timer == 5
	move_in = true;
if timer == 30 || timer == 19
	lerp_up_to++;

for (var i = 0; i < lerp_up_to; i++) {
	var circle = circles[i];
	circle.radius = lerp(circle.radius, max_radius, 0.5)
	if move_in {
		circle.distance = lerp(circle.distance, 0, 0.5)
	}
	else {
		circle.distance = lerp(circle.distance, max_distance, 0.5)
	}
}

x = mouse_x
y = mouse_y
add_angle += 1