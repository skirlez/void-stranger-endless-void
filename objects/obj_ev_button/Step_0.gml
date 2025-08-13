
var scale = 1;
var mouse_on_me = pressable && ev_is_mouse_on_me();

if global.allow_moving_elements && mouse_check_button(mb_middle) && ev_is_mouse_on_me() {
	x = mouse_x
	y = mouse_y
	mouse_on_me = false;
	log_info($"{mouse_x}, {mouse_y}")
}


if (selected && hover_state != 1) {
	hover_state = 1;	
}

if hover_state == 0 {
	if mouse_on_me
		hover_state = 1;	
	
}


else if hover_state == 1 {
	if hover_time < 100 {
		hover_time += 5
		scale += animcurve_channel_evaluate(hover_curve, hover_time / 100) / 5
	}
	else
		scale = 1.2
	if !mouse_on_me && !selected {
		hover_time = 100
		hover_state = 2	
	}
	
}
else if hover_state == 2 {
	hover_time -= 5
	scale += animcurve_channel_evaluate(unhover_curve, hover_time / 100) / 5
	if mouse_on_me
		hover_state = 1
}


hover_time = clamp(hover_time, 0, 100)

if animated {
	scale_x = scale * base_scale_x
	scale_y = scale * base_scale_y
}


if pressable && ev_mouse_pressed() && mouse_on_me
	event_user(0)
