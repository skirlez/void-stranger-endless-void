event_inherited();

if pack_mode {
	if (ds_map_exists(global.pack_key_map, save_name)) {
		ev_notify("Can't delete an uploaded pack!\nDelete it from the server first.")
		audio_play_sound(pluck, 0, false, 1, 0, 0.6)
		exit
	}
}
else {
	if (ds_map_exists(global.level_key_map, save_name)) {
		ev_notify("Can't delete an uploaded level!\nDelete it from the server first.")
		audio_play_sound(pluck, 0, false, 1, 0, 0.6)
		exit
	}
}


timer = max_time
deleting = true
audio_play_sound(pluck, 0, false)