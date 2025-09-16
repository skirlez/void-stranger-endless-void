audio_play_sound(snd, 10, false)
image_index = !image_index	
with (agi("obj_ev_level_settings_window"))
	commit()
		
if ((burden_ind != burden_types.stackrod || burden_ind != burden_types.swapper) 
		&& global.level.music == "msc_test2") {
	var pos = audio_sound_get_track_position(global.music_inst)
	ev_play_music(agi("msc_test2"))
	audio_sound_set_track_position(global.music_inst, pos);
}