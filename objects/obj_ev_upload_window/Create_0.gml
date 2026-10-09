event_inherited();

if level_or_save_name == noone
	exit

if is_pack
	subject = import_pack(read_pack_string_from_file(level_or_save_name))
else
	subject = level_or_save_name
function can_upload_level(level) {
	var sha = level_content_sha1(level);
	if !ds_map_exists(global.beaten_levels_map, sha)
		return false;
		
	var value = ds_map_find_value(global.beaten_levels_map, sha)
	if level_contains_crystal_memory(level)
		return (value == 2)
	return (value == 1)
}

function can_upload_pack(pack) {
	return true;
}

function can_upload_level_or_pack(level_or_pack) {
	if (is_pack) {
		return can_upload_pack(level_or_pack);
	} else {
		return can_upload_level(level_or_pack);
	}
}

function export_level_or_pack(level_or_pack) {
	if (is_pack) {
		return export_pack(level_or_pack);
	} else {
		return export_level(level_or_pack);
	}
}

function find_key() {
	if (is_pack) {
		return ds_map_find_value(global.pack_key_map, subject.save_name);
	} else {
		return ds_map_find_value(global.level_key_map, subject.save_name);
	}
}

function remove_key() {
	if (is_pack) {
		return global.editor.remove_pack_key(subject.save_name);
	} else {
		return global.editor.remove_level_key(subject.save_name);
	}
}

function add_key() {
	if (is_pack) {
		return global.editor.add_pack_key(verifying_key, subject.save_name);
	} else {
		return global.editor.add_level_key(verifying_key, subject.save_name);
	}
}

function get_mode_name() {
	if (is_pack) {
		return "pack";
	} else {
		return "level";
	}
}

function get_server_path() {
	if (is_pack) {
		return global.packs_server;
	} else {
 		return global.levels_server;
	}
}

function get_save_directory() {
	if (is_pack) {
		return global.packs_directory;
	} else {
 		return global.levels_directory;
	}
}



are_you_sure_upload_text = "This" + ((irandom($7fffffffffffffff) == 40) ? " stupid " : " ") + get_mode_name() + " is not uploaded.\nDo you want to upload it?"
are_you_sure_delete_text = "Are you sure you want to\n delete this " + get_mode_name() + "? It will\nnot be deleted locally."
doing_the_thing_text = "Doing the thing..."
verifying_text = "Verifying upload..."
done_text = "Done!\nThe thing you tried doing\nwas successful!"
fail_text = "Something went wrong.\nError message:\n"
manage_text = "This " + get_mode_name() + " is uploaded.\nWhat would you like to do?"
no_idea_text = "I have no idea whether\nwhether or not this " + get_mode_name() +"\nhas uploaded correctly."
beat_first_text = "Clear the " + get_mode_name() + " outside\nthe editor first!"
and_memory_crystal_text = "(and get the Memory Crystal)"


post_level_id = noone
update_level_id = noone
delete_level_id = noone
post_level_verify_id = noone

verifying_key = ""
if !is_undefined(find_key()) {
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
	if !can_upload_level_or_pack(subject) {
		state = 8;
		reset_window()
		create_finish_buttons("Ah")
		return;
	}
	state = 1;
	upload_timeout = 300
	reset_window()
	
	var subject_str = export_level_or_pack(subject);
	post_level_id = http_post_string(get_server_path(), subject_str)
}

function start_updating() {
	if !can_upload_level_or_pack(subject) {
		state = 8;
		reset_window()
		create_finish_buttons("Ah")
		return;
	}

	state = 1;
	upload_timeout = 300
	reset_window()
	
	var subject_str = export_level_or_pack(subject);
	var key = find_key(subject.save_name);

	var map = ds_map_create();
	update_level_id = http_request(get_server_path(), "PUT", map, subject_str + "|" + key)
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
	
	var key = find_key()

	var map = ds_map_create();
	delete_level_id = http_request(get_server_path(), "DELETE", map, key)
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
	post_level_verify_id = http_post_string(get_server_path() + "/orphanage", key)
}
function on_verify_upload() {
	state = 2
	global.editor.try_update_online_levels();

	add_key()
	
	var keyfile = file_text_open_write(get_save_directory() + subject.save_name + ".key")
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
	remove_key()
	file_delete(get_save_directory() + subject.save_name + ".key")
}

