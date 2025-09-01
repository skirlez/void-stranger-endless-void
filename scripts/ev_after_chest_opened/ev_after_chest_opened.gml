
// called from gml_Object_obj_chest_small_Alarm_0
function after_chest_opened() {
	if ev_is_elysium_music_playing() && (contents == 2 || contents == 3 or contents == 4) {
		var pos = audio_sound_get_track_position(global.music_inst)
		ev_play_music(ev_get_elysium_music_gameplay(), true, true)
		audio_sound_set_track_position(global.music_inst, pos);
	}
	if room == global.pack_level_room && (contents == 1 || contents == 6) {
		static pack_player = agi("obj_ev_pack_player")
		ds_map_set(global.locusts_collected_this_level, (y div 16) * 14 + (x div 16), true)
		if instance_exists(pack_player) {
			if contents == 1
				pack_player.total_locusts_collected++;
			else if contents == 6
				pack_player.total_locusts_collected += 3;
		}
	}
}