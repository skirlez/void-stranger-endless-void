if is_online {
	online_pack_str = get_online_pack_string(nodeless_pack.save_name)
}

var can_play = global.is_merged && !(is_online && is_undefined(online_pack_str))
if (can_play) {
	event_inherited()
	if (highlighter != noone)
		highlighter.hide_textbox();
	if (nodeless_pack != noone && display_instance != noone) {
		if tis {
			global.pack_parameters = create_pack_parameters([true, true, true, true, true], 0, true, -1);
			if !global.tis_pack_button {
				global.tis_pack_button = true
				ev_save()
			}
		}
		else
			global.pack_parameters = create_pack_parameters()
		if is_online {
			global.editor.play_pack_string_transition(online_pack_str, display_instance)
		}
		else
			global.editor.play_pack_transition(nodeless_pack, display_instance)
	}
}
else
	audio_play_sound(agi("snd_reveal"), 10, false)