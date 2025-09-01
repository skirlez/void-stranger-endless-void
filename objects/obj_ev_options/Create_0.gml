event_inherited();

function can_commit() {
	var length = string_length(author_textbox.txt)
	return (length > 0)
}

function commit() {
	global.author.username = author_textbox.txt
	global.author.brand = author_brand.brand;
	global.server_ip = server_textbox.txt;
	global.server_port = int64_safe(port_textbox.txt, 3000)
	global.logging_ip = log_ip_textbox.txt;
	global.logging_port = int64_safe(log_port_textbox.txt, 1235)
	global.should_log_udp = log_toggle.image_index;
	global.disable_3d_cube_bs = cube_toggle.image_index;
	ev_save()	
	ev_update_vars()
}


save_server_ip_and_port = $"{global.server_ip}:{global.server_port}";

instance_create_layer(200, 16, "Instances", agi("obj_ev_executing_button"), {
	base_scale_x : 1,
	base_scale_y : 0.7,
	txt : "Back",
	room_name : "rm_ev_menu",
	func : function () {
		var options = agi("obj_ev_options");
		with (options) {
			if (can_commit()) {
				commit();
				if save_server_ip_and_port != $"{global.server_ip}:{global.server_port}"
					room_goto(agi("rm_ev_startup"))
				else
					room_goto(agi("rm_ev_menu"))
			}
		}
	}
});

instance_create_layer(38, 120, "Instances", agi("obj_ev_executing_button"), {
	base_scale_x : 1.7,
	base_scale_y : 0.7,
	txt : "Random",
	func : function () {
		agi("obj_ev_make_brand").brand = int64(irandom_range(0, $FFFFFFFFF))
	}
});
author_brand = instance_create_layer(38, 87, "Instances", agi("obj_ev_make_brand"), {
	brand : global.author.brand
})
add_child(author_brand)

change_character = instance_create_layer(139, 78, "Instances", agi("obj_ev_change_character"));
add_child(change_character)
/* Maybe one day, but today ain't the day
change_memory = instance_create_layer(112 - 46, 72 + 30, "Instances", agi("obj_ev_change_memory"));
add_child(change_memory)
change_wings = instance_create_layer(112 - 30, 72 + 30, "Instances", agi("obj_ev_change_wings"));
add_child(change_wings)
change_blade = instance_create_layer(112 - 14, 72 + 30, "Instances", agi("obj_ev_change_blade"));
add_child(change_blade)
*/

author_textbox = instance_create_layer(39, 57, "Textboxes", agi("obj_ev_textbox"), 
{
	empty_text : "Username",
	allow_newlines : false,
	automatic_newline : false,
	char_limit : 30,
	base_scale_x : 4,
	txt : global.author.username
})
add_child(author_textbox)


server_textbox = instance_create_layer(64, 32, "Textboxes", agi("obj_ev_textbox"), 
{
	empty_text : "Server IP",
	allow_newlines : false,
	automatic_newline : true,
	opened_x : 112,
	opened_y : 72,
	char_limit : 300,
	base_scale_x : 7.1,
	txt : global.server_ip
})
add_child(server_textbox)

port_textbox = instance_create_layer(112 + 36, 72 - 40, "Textboxes", agi("obj_ev_textbox"), 
{
	empty_text : "Port",
	allow_newlines : false,
	allow_alphanumeric : false,
	automatic_newline : false,
	exceptions : "0123456789",
	opened_x : 112,
	opened_y : 72,
	char_limit : 7,
	base_scale_x : 3,
	txt : string(global.server_port)
})
add_child(port_textbox)
add_child(server_textbox)



cube_toggle = instance_create_layer(112, 144 + 40, "Instances", agi("obj_ev_toggle"), {
	image_index : global.disable_3d_cube_bs	
})
add_child(cube_toggle)

cube_toggle_explanation = instance_create_layer(112, 144 + 20, "Instances2", agi("obj_ev_textbox"), {
	allow_deletion : false,
	char_limit : 0,
	opened_x : 112,
	opened_y : 72 + 144,
	txt : "This toggle disables some trickery Endless Void does for the 3D cube in the level editor. Enable it if you're experiencing issues.",
})
add_child(cube_toggle_explanation)


log_toggle_explanation = instance_create_layer(112, 144 + 80, "Instances2", agi("obj_ev_textbox"), {
	allow_deletion : false,
	char_limit : 0,
	opened_x : 112,
	opened_y : 72 + 144,
	txt : "This toggle enables logging. The two textboxes below are the IP and port where the logs should be sent. You can use github.com/Skirlez/slip to receive logs.",
})
add_child(log_toggle_explanation)

log_toggle = instance_create_layer(112, 144 + 100, "Instances", agi("obj_ev_toggle"), {
	image_index : global.should_log_udp	
})
add_child(log_toggle)


log_ip_textbox = instance_create_layer(112 - 36, 144 + 120, "Instances", agi("obj_ev_textbox"), 
{
	empty_text : "Logging IP",
	allow_newlines : false,
	automatic_newline : false,
	char_limit : 100,
	base_scale_x : 4.5,
	txt : global.logging_ip
})
add_child(server_textbox)
log_port_textbox = instance_create_layer(112 + 36, 144 + 120, "Textboxes", agi("obj_ev_textbox"), 
{
	empty_text : "Port",
	allow_newlines : false,
	allow_alphanumeric : false,
	automatic_newline : false,
	exceptions : "0123456789",
	char_limit : 7,
	base_scale_x : 3,
	txt : string(global.logging_port)
})
add_child(log_ip_textbox)
add_child(log_port_textbox)



function switch_page(new_page) {
	if new_page > max_page
		new_page = 0
	else if new_page < 0
		new_page = max_page
	current_page = new_page;
}
max_page = 2;
current_page = 0;


scroll_button_down = instance_create_layer(200, 88, "Instances", agi("obj_ev_executing_scroll_button"), {
	func : function () {
		with (window) {
			switch_page(current_page + 1)
			// don't cancel press
			global.mouse_pressed = true;
		}
	}
})
scroll_button_up = instance_create_layer(200, 56, "Instances", agi("obj_ev_executing_scroll_button"), {
	image_index : 1,
	func : function () {
		with (window) {
			switch_page(current_page - 1)
			// don't cancel press
			global.mouse_pressed = true;
		}
	}
})

vanilla_options = instance_create_layer(139, 120, "Instances", agi("obj_ev_executing_button"), {
	txt : "VS Options",
	base_scale_x : 2.2,
	base_scale_y : 0.7,
	func : function () {
		if global.is_merged {
			// makes burdens menu hidden
			ev_prepare_level_burdens()
			with (agi("obj_pause")) {
				agi("obj_menu").image_speed = 0
				agi("obj_menu").menu_art_x = 160
				global.pause = true
				global.timer_count = false
				alarm[1] = 40
				agi("scr_loadmenu")()
				instance_create_layer(x, y, "Pause", agi("obj_fade_black_in"))
				agi("obj_music_controller").alarm[1] = 1
				with (agi("obj_menu"))
					transition = true
				transition = true
				alarm[4] = 80
			}
			
			// used in step to restore mouse_layer once options menu is gone
			window.in_options = true;
			global.mouse_layer = 1;
		}
		else
			audio_play_sound(snd_reveal, 10, false)
	}
})
add_child(vanilla_options)
in_options = false;



those_who_special = [scroll_button_down, scroll_button_up]
add_child(scroll_button_down)
add_child(scroll_button_up)



question = instance_create_layer(112, 144 * 2 + 72, "Instances", agi("obj_ev_executing_button"), {
	txt : "?",
	func : function () {
		if global.is_merged {
			global.mouse_layer++;
			instance_create_layer(0, 0, "EditorObject", agi("obj_ev_question_mark_darkness"));
		}
	}
})
add_child(question)


textbox_depth = layer_get_depth(layer_get_id("Textboxes"))