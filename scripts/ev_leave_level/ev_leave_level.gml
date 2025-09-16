
function ev_leave_level() {
	if (global.playtesting)
		room_goto(agi("rm_ev_editor"))
	else
		room_goto(agi("rm_ev_level_select"))
	global.playtesting = false;
	ev_switch_to_user_palette()
	global.editor.reset_branefuck_persistent_memory()
	ds_map_clear(global.locusts_collected_this_level)
}

function ev_clear_level() {
	if (global.level_sha != "" && !global.debug && !global.playtesting) {
		var sha = global.level_sha;

		var gotten_crystal = (global.token_check != 0)
		
		var exists = ds_map_exists(global.beaten_levels_map, sha)
		if exists {
			var current = ds_map_find_value(global.beaten_levels_map, sha)
			if current == 2 || (current == 1 && !gotten_crystal) {
				ev_leave_level();
				return;
			}
		}
		
		if gotten_crystal
			ds_map_set(global.beaten_levels_map, sha, 2)
		else 
			ds_map_set(global.beaten_levels_map, sha, 1)
		global.editor.save_beaten_levels();
	}
	ev_leave_level();
}