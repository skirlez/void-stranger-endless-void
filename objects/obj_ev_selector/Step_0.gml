if state == selector_states.displaying {
	if ev_is_mouse_on_me() && ev_mouse_pressed() {
		global.mouse_layer++;
		audio_play_sound(agi("snd_ev_selector_click"), 10, false)
		var angle = 0;
		var angle_increase = 360 / array_length(elements)

		element_objects = []

		for (var i = 0; i < array_length(elements); i++) {
			var _depth = layer_get_depth(layer_get_id("WindowElements2"))
			if i == selected_element
				_depth--;
			var element = instance_create_depth(xstart, ystart, _depth, agi("obj_ev_selector_element"), {
				txt : elements[i],
				index : i,
				selector : id,
				max_radius : max_radius,
				layer_num : global.mouse_layer,
				angle : angle
			})	
			angle += angle_increase
			array_push(element_objects, element)

		}

		state = selector_states.selecting;

	}
}


if state == selector_states.animating {
	animation_time++;
	
	if animation_time == 50 {
		state = selector_states.displaying
		animation_time = 0;
		animation_elements_progress = 0;
		bounces = 0;
		bounce_text = ""
		exit;
	}
	
	if (animation_time < animation_length - 15) {
		if (animation_time / (animation_length - 15)) * array_length(element_objects) > animation_elements_progress {
			element_objects[animation_elements_progress].start_return_animation();
			animation_elements_progress++;
		}
	}
}

y_bounce += vsp
vsp -= 0.5;

if y_bounce < 0 {
	y_bounce = 0;
	vsp = 0;
}