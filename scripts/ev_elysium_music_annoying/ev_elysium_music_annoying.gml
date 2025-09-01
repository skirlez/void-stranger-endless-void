global.elysium_tracks = [agi("msc_test2"), agi("msc_ending2"),
		agi("msc_looptest"), agi("msc_sendoff")]
		
function ev_get_elysium_music(level) {
	var track = 0;
	for (var i = 0; i < 3; i++) {
		if (level.burdens[i])
			track++;	
	}
	return global.elysium_tracks[track]
}

function ev_get_elysium_music_gameplay() {
	var index = 0;
	with (agi("obj_inventory")) {
		if (ds_grid_get(ds_equipment, 0, 2) == 3)
			index++
		if (ds_grid_get(ds_equipment, 0, 1) == 2)
			index++
		if (ds_grid_get(ds_equipment, 0, 0) == 1)
			index++
	}
	return index;
}


function ev_is_music_elysium(track) {
	return ev_array_contains(global.elysium_tracks, track)
}
function ev_is_elysium_music_playing() {
	for (var i = 0; i < 4; i++) {
		if audio_is_playing(global.elysium_tracks[i])
			return true
	}
	return false
}
// called from gml_Object_obj_chest_small_Alarm_0
function after_chest_opened() {
	if ev_is_elysium_music_playing() && contents == 2 || contents == 3 or contents == 4 {
		var pos = audio_sound_get_track_position(global.music_inst)
		ev_play_music(ev_get_elysium_music_gameplay(), true, true)
		audio_sound_set_track_position(global.music_inst, pos);
	}
}