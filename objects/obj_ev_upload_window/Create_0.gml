event_inherited();

if lvl == noone
	exit
	


function can_upload_level(level) {
	var sha = level_content_sha1(level);
	if !ds_map_exists(global.beaten_levels_map, sha)
		return false;
		
	var value = ds_map_find_value(global.beaten_levels_map, sha)
	if level_contains_crystal_memory(level)
		return (value == 2)
	return (value == 1)
}



are_you_sure_upload_text = "This" + ((irandom($7fffffffffffffff) == 40) ? " stupid " : " ") + "level is not uploaded.\nDo you want to upload it?"
are_you_sure_delete_text = "Are you sure you want to\n delete this level? It will\nnot be deleted locally."
doing_the_thing_text = "Doing the thing..."
verifying_text = "Verifying upload..."
done_text = "Done!\nThe thing you tried doing\nwas successful!"
fail_text = "Something went wrong.\nError message:\n"
manage_text = "This level is uploaded.\nWhat would you like to do?"
no_idea_text = "I have no idea whether\nwhether or not this level\nhas uploaded correctly."
beat_first_text = "Clear the level outside\nthe editor first!"
and_memory_crystal_text = "(and get the Memory Crystal)"


post_level_id = noone
update_level_id = noone
delete_level_id = noone
post_level_verify_id = noone

verifying_key = ""
if ds_map_exists(global.level_key_map, lvl.save_name) {
	state = 4
	var updateb = instance_create_layer(112 - 60, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : "Update",
		base_scale_x : 1.6,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		func : function() {
			window.start_updating();
		}
	})

	var deleteb = instance_create_layer(112, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : "Delete",
		base_scale_x : 1.3,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		func : function() {
			window.ask_deleting();
		}
	})
	
	var nothing = instance_create_layer(112 + 60, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : "Nothing",
		base_scale_x : 1.6,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		func : function() {
			instance_destroy(window)
		}
	})
	
	add_child(updateb)
	add_child(deleteb)
	add_child(nothing)	
	
}
else {
	state = 0
	var no = instance_create_layer(112 + 30, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : "No",
		base_scale_x : 0.8,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		func : function() {
			instance_destroy(window)
		}
	})

	var yes = instance_create_layer(112 - 30, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : "Yes",
		base_scale_x : 0.8,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		func : function() {
			window.start_uploading();
		}
	})

	add_child(no)
	add_child(yes)	
	
}
upload_timeout = 0
verify_timeout = 0
function reset_window() {
	selected_element = noone;
	for (var i = 0; i < array_length(children); i++) {
		instance_destroy(children[i]);	
	}
	children = []	
}

function start_uploading() {
	if !can_upload_level(lvl) {
		state = 8;
		reset_window()
		create_finish_buttons("Ah")
		return;
	}
	state = 1;
	upload_timeout = 300
	reset_window()
	
	var lvl_str = export_level(lvl);
	post_level_id = http_post_string(global.server, lvl_str)
}

function start_updating() {
	if !can_upload_level(lvl) {
		state = 8;
		reset_window()
		create_finish_buttons("Ah")
		return;
	}

	state = 1;
	upload_timeout = 300
	reset_window()
	
	var lvl_str = export_level(lvl);
	var map = ds_map_create();
	var key = ds_map_find_value(global.level_key_map, lvl.save_name)

	update_level_id = http_request(global.server, "PUT", map, lvl_str + "|" + key)
	ds_map_destroy(map)
}
function ask_deleting() {
	state = 5;
	reset_window()
	var no = instance_create_layer(112 + 30, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : "No",
		base_scale_x : 0.8,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		func : function() {
			instance_destroy(window)
		}
	})

	var yes = instance_create_layer(112 - 30, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : "Yes",
		base_scale_x : 0.8,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		func : function() {
			window.start_deleting();
		}
	})
	add_child(no)
	add_child(yes)
}


function start_deleting() {
	state = 1;
	upload_timeout = 300
	reset_window()
	
	var map = ds_map_create();
	var key = ds_map_find_value(global.level_key_map, lvl.save_name)

	delete_level_id = http_request(global.server, "DELETE", map, key)
	ds_map_destroy(map)
}




function create_finish_buttons(ok_text) {
	var ok = instance_create_layer(112, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : ok_text,
		base_scale_x : 2.6,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		func : function() {
			instance_destroy(window)
		}
	});
	add_child(ok);
	add_x_button()
}
function on_fail(error_str = "") {

	post_level_id = noone
	update_level_id = noone
	delete_level_id = noone
	upload_timeout = 0;
	state = 3
	
	error_textbox = instance_create_layer(112, 80, "WindowElements", agi("obj_ev_textbox"), 
	{
		txt : error_str,
		base_scale_x : 6,
		base_scale_y : 1,
		layer_num : 1,
		allow_deletion : false,
		char_limit : 0,	
	})
	add_child(error_textbox)
	
	create_finish_buttons("Oh damn")
}

function on_finish_upload(key) {
	state = 6
	verify_timeout = 500
	verifying_key = key;
	post_level_verify_id = http_post_string(global.server + "/orphanage", key)
}
function on_verify_upload() {
	state = 2
	global.editor.try_update_online_levels();
	global.editor.add_level_key(verifying_key, lvl.save_name)
	
	var keyfile = file_text_open_write(global.levels_directory + lvl.save_name + ".key")
	file_text_write_string(keyfile, verifying_key)
	file_text_close(keyfile)
	
	create_finish_buttons("Okay thanks") 
}
function on_fail_verify() {
	state = 7;
	create_finish_buttons("That's crazy")
}
function on_finish_update() {
	state = 2
	create_finish_buttons("Okay thanks") 
	global.editor.try_update_online_levels();
}
function on_finish_delete() {
	state = 2
	create_finish_buttons("Okay thanks") 
	global.editor.try_update_online_levels();
	global.editor.remove_level_key(lvl.save_name)
	
	file_delete(global.levels_directory + lvl.save_name + ".key")
}

