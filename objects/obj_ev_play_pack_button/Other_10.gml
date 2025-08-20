if (global.is_merged) {
	event_inherited()
	if (highlighter != noone)
		highlighter.hide_textbox();
	if (nodeless_pack != noone && display_instance != noone) {
		if tis {
			global.pack_parameters = create_pack_parameters([true, true, true, true, true], 0, true, -1);
			global.tis_pack_button = true;
			ev_save()
		}
		else
			global.pack_parameters = create_pack_parameters()
		global.editor.play_pack_transition(nodeless_pack, display_instance, tis)
	}
}
else
	audio_play_sound(snd_reveal, 10, false)