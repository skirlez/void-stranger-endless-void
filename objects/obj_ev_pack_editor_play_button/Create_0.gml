event_inherited()
base_scale_x_start = base_scale_x
base_scale_y_start = base_scale_y
window_sprite = agi("spr_ev_window")

window_size = 0;

window_xscale = 6;
window_yscale = 3;

chudlings = []
locust_textbox = noone;

function get_playtest_parameters() {
	var burdens = array_create(array_length(chudlings), 0)
	for (var i = 0; i < array_length(chudlings); i++) {
		burdens[i] = chudlings[i].image_index	
	}
	return create_pack_parameters(burdens, 0, false, -1)	
}

function update_chudlings_position() {
	var pos_x = camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) / 2
	var pos_y = camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]) / 3
	
	var padding = 15;
	
	var top = pos_y - (16 * window_yscale * window_size) / 2 + padding * window_size
	var left = pos_x - (16 * window_xscale * window_size) / 2 + padding * window_size

	for (var i = 0; i < array_length(chudlings); i++) {
		chudlings[i].x = left + i * (16 * window_size);
		chudlings[i].y = top
	}
}

global.pack_editor.select_tool_happening.subscribe(function (struct) {
	selected = (struct.new_selected_thing == pack_things.play)

	if (array_length(chudlings) != 0) {
		for (var i = 0; i < array_length(chudlings); i++)
			instance_destroy(chudlings[i])
		chudlings = []
	}
	if instance_exists(locust_textbox)
		instance_destroy(locust_textbox)

	if selected {
		for (var i = 0; i < 5; i++) {
			var instance = instance_create_layer(x, y, "WindowElements", agi("obj_ev_pack_burden_toggle"))
			instance.burden_ind = i;
			array_push(chudlings, instance)
		}
		/*
		locust_textbox = instance_create_layer(112, 72, "WindowElements", agi("obj_ev_textbox"), {
			txt : "",
			allow_alphanumeric : false,
			exceptions : "0123456789",
			char_limit : 2,
			base_scale_x : 1.4,
			base_scale_y : 1,
		});
		*/
		update_chudlings_position()	
	}
})
