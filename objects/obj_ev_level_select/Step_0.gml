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
			var local_pack_exists = file_exists(global.packs_directory + pack.save_name + "." + pack_extension)
			var online_nodeless_pack_if_exists = noone;
			if !local_pack_exists {
				for (var i = 0; i < array_length(global.online_packs); i++) {
					var nodeless = import_pack_nodeless(global.online_packs[i])
					if (nodeless.save_name == pack.save_name) {
						online_nodeless_pack_if_exists = nodeless;
						break;
					}
				}
			}
			if local_pack_exists || (online_nodeless_pack_if_exists != noone) {
				var preexisting_nodeless_pack;
				if local_pack_exists {
					try {
						var old_pack_string = read_pack_string_from_file(pack.save_name, true)
						preexisting_nodeless_pack = import_pack_nodeless(old_pack_string)
					}
					catch (e) {
						ev_notify("Couldn't paste pack!")
						exit;
					}
				}
				else
					preexisting_nodeless_pack = online_nodeless_pack_if_exists
					
				global.mouse_layer++;
				new_window(13, 8, agi("obj_ev_update_pack_window"), {
					layer_num : global.mouse_layer,
					old_nodeless_pack : preexisting_nodeless_pack,
					new_pack : pack,
					new_pack_string : str,
					is_online_collision : (online_nodeless_pack_if_exists != noone),
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

