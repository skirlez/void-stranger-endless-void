if !transition {
	if animate {
		timer++;
		if timer >= 180
			animate = false;
	}
	else {
		if global.is_merged {
			dust_emit_counter++;
			if dust_emit_counter > dust_emit_limit {
				var dp_amount = irandom_range(10, 14)
				for (var j = 0; j < dp_amount; j++) {
					var dp_x = irandom_range(-16, 32)
					var dp_x2 = irandom_range(192, 240)
					var dp_y = irandom_range(10, 14)
					instance_create_depth(dp_x, (dp_y * j), 50, agi("obj_dustparticle"))
					instance_create_depth(dp_x2, (dp_y * j), 50, agi("obj_dustparticle"))
				}
				dust_emit_counter = 0;
				dust_emit_limit = irandom_range(128, 144)
			}
		}
		
		if ev_mouse_pressed() || ev_mouse_right_pressed() {
			ev_stop_music()
			if global.is_merged
				instance_destroy(agi("obj_dustparticle"))
			transition = true
			audio_play_sound(agi("snd_ev_start_pretitle"), 10, false)
		}
	}
}
else {
	x = lerp(x, 0, 0.155)
	y = lerp(y, 0, 0.155)
	transition_timer++;
	if transition_timer > 40
		room_goto(agi("rm_ev_menu"))
}