global.mouse_layer = 0
global.mouse_held = false;
global.mouse_pressed = false;


if room == agi("rm_ev_menu") || room == agi("rm_ev_level_select") || room == agi("rm_ev_pack_select") {
	history = []
	global.level_sha = "";
	var music = global.menu_music;
	if !audio_is_playing(music)
		ev_play_music(music)
		
	// resets jukebox state
	global.jukebox_song = 0;
}

if room == agi("rm_ev_editor") {
	draw_set_circle_precision(48)
	if (!ev_is_music_playing(agi(global.level.music))) {
		ev_play_music(agi(global.level.music))
	}
	else if ev_is_elysium_music_playing() 
			&& global.music_file != ev_get_elysium_music(global.level) {
		var pos = audio_sound_get_track_position(global.music_inst)
		ev_play_music(ev_get_elysium_music(global.level), true, true)
		audio_sound_set_track_position(global.music_inst, pos);
	}
}
else {
	var quill = agi("obj_quill")
	if quill != -1
		instance_destroy(quill)	
}
if (room == agi("rm_ev_startup")) {
	read_beaten_levels()
	
	uploaded_levels = get_all_files(global.levels_directory, "key")
	uploaded_keys = array_create(array_length(uploaded_levels), "")

	for (var i = 0; i < array_length(uploaded_levels); i++) {
		var save_name = uploaded_levels[i] 
		var file = file_text_open_read(global.levels_directory + save_name + ".key")
		var key = file_text_read_string(file);
		uploaded_keys[i] = key;
		file_text_close(file)
	}
	
	global.online_levels = []
	startup_timeout = 300; // amount of frames before we give up
	startup_actions_count = 3; 
	try_update_online_levels()
	if array_length(uploaded_keys) != 0 {
		var build = uploaded_keys[0];
		for (var i = 1; i < array_length(uploaded_levels); i++) {
			build += "," + uploaded_keys[i]	
		}
		validate_levels = http_get(global.server + "/" + build)
	}
	else
		startup_actions_count--;
	request_version_string()
}

if (ev_is_room_gameplay(room)) {
	global.level_time = 0;
	last_deaths = 0
	last_deaths += ds_list_find_value(agi("obj_inventory").ds_rcrds, 5)
	last_deaths += ds_list_find_value(agi("obj_inventory").ds_rcrds, 6)
	global.death_x = -1
	global.death_y = -1
	global.annoyance_count = 0
}

global.turn_frames = 0