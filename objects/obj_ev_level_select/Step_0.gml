event_inherited();

if keyboard_check(vk_control) && keyboard_check_pressed(ord("V")) && !global.online_mode {
	if mode == level_selector_modes.levels {
		var str = clipboard_get_text();
		var version = read_string_until(str, 1, "|").substr
		if !string_is_uint(version) 
			exit;
		if int64_safe(version) > global.latest_lvl_format {
			ev_notify("Unsupported level version! Update EV!")
			exit;
		}
	
		try {
			var file = file_text_open_write(global.levels_directory + generate_ulid() + "." + level_extension)
			file_text_write_string(file, str);
			file_text_close(file)
			ev_notify("Level pasted!")
		}
		catch (e) {
			ev_notify("Couldn't paste level!")	
			log_error(e)
		}


		on_level_update();
	}
	else if mode == level_selector_modes.packs {
		var str = clipboard_get_text();
		var version = read_string_until(str, 1, "&").substr
		if !string_is_uint(version)
			exit;
		if int64_safe(version) > global.latest_pack_format {
			ev_notify("Unsupported pack version! Update EV!")
			exit;
		}
		
		if version == 1 {
			ev_notify("Couldn't paste pack!")
			exit;
		}
		else {
			var pack = import_pack(str);
			if file_exists(global.packs_directory + pack.save_name + "." + pack_extension) {
				var old_pack_string;
				try {
					var file = file_text_open_read(global.packs_directory + pack.save_name + "." + pack_extension)
					old_pack_string = file_text_read_string(file)
					file_text_close(file)
				}
				catch (e) {
					ev_notify("Couldn't paste pack!")
					exit;
				}
					
				global.mouse_layer++;
				new_window(11, 8, agi("obj_ev_update_pack_window"), {
					layer_num : global.mouse_layer,
					old_pack : import_pack(old_pack_string),
					new_pack : pack,
					old_pack_string : old_pack_string,
					new_pack_string : str,
					level_select : id,
				})
			}
			else {
				try {
					var file = file_text_open_write(global.packs_directory + pack.save_name + "." + pack_extension)
					file_text_write_string(file, str);
					file_text_close(file)
					ev_notify("Pack pasted!")
				}
				catch (e) {
					ev_notify("Couldn't paste pack!")
				}
			}
		}
		on_level_update();
	}
}

