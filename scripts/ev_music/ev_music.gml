

// if dont_subt_ex_track is true, it will not substitute the EX track with a different one by trying to read the amount of burdens
function ev_play_music(track, looping = true, dont_subt_ex_track = false) {
	ev_stop_music()
	if (track == -1) {
		return;
	}
	if global.is_merged {
		if (!dont_subt_ex_track && audio_get_name(track) == "msc_test2") {
			if room == global.editor_room || room == global.level_room || room == global.pack_level_room
				track = ev_get_elysium_music(global.level)
			agi("scr_play_music")(track, looping, 1)
		}
		else {
			agi("scr_play_music")(track, looping)
		}
	}
	else { 
		if ((room == global.editor_room || room == global.level_room) && audio_get_name(track) == "msc_test2") {
			track = ev_get_elysium_music(global.level);
		}
		var start = ev_get_real_track_start(track);
		global.music_inst = audio_play_sound(track, 10, looping, 1, start)
		global.music_is_looping = looping
		/* function doesn't exist in VS and fixing that would be annoying
		if looping {
			audio_sound_loop_end(global.music_inst, ev_get_real_song_end(global.music_inst))
		}
		*/
	}
}

function ev_is_music_playing(track) {
	return audio_is_playing(track) 
		|| (ev_is_music_elysium(track) && ev_is_elysium_music_playing())
}

function ev_stop_music() {
	if global.is_merged {
		global.music_file = noone
		agi("scr_stop_music")(0)
	}
	else {
		audio_stop_sound(global.music_inst)
		global.music_inst = noone;
	}
}
