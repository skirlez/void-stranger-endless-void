if ds_map_find_value(async_load, "id") == get_levels
{
	if ds_map_find_value(async_load, "status") == 0 {
		online_levels_str = ds_map_find_value(async_load, "result");
		if (online_levels_str != "" && !is_undefined(online_levels_str))
			global.online_levels = ev_string_split_buffer(online_levels_str, ",", 512)
		else
			global.online_levels = []

		with (agi("obj_ev_level_select"))
			on_level_update();
		with (agi("obj_ev_refresh_window"))
			on_level_update();	
		
	
		if (room == global.startup_room) {
			startup_actions_count--;
		}
	}
}
else if ds_map_find_value(async_load, "id") == validate_levels
{
	if ds_map_find_value(async_load, "status") == 0 {
		var result = ds_map_find_value(async_load, "result");

		on_server_validate_startup(result)
		if (room == global.startup_room) {
			startup_actions_count--;
		}
	}

}
else if ds_map_find_value(async_load, "id") == get_version
{
	if ds_map_find_value(async_load, "status") == 0 {
		var result = ds_map_find_value(async_load, "result");
		var latest_version = real_safe(result)
		global.there_is_a_newer_version = (latest_version > real(global.ev_version))
		global.newest_version = result
		if (room == global.startup_room) {
			startup_actions_count--;
		}
	}

}