event_inherited();

if (level_select == noone)
	exit

if deleting && (!ev_is_mouse_on_me() || !mouse_check_button(mb_left)) {
	deleting = false
	image_index = 0;
	image_speed = 0;
	layer = layer_get_id("LevelHighlightButtons")
	instance_destroy(agi("obj_ev_delete_pack_save_visuals"))
	audio_stop_sound(agi("snd_punch_anticipation"))
	audio_resume_sound(global.music_inst)
}

if deleting {
	if timer == 0 {
		image_speed = 1.5;	
	}
	timer++;
	if timer == 60 {
		image_speed = 0;
		image_index = 0;
		audio_play_sound(agi("snd_punch_anticipation"), 10, false)
		instance_create_layer(0, 0, "DeleteSaveVisuals", agi("obj_ev_delete_pack_save_visuals"))
	}
	if timer == 580 {
		delete_pack_progress(save_name)
		audio_resume_sound(global.music_inst)
		var file = file_text_open_read(global.packs_directory + save_name + "." + pack_extension)
		if file == -1 {
			deleting = false;
			exit;
		}
		var str = file_text_read_string(file);
		file_text_close(file);
		global.pack = import_pack(str)
		global.pack_parameters = create_pack_parameters()
		room_goto(global.pack_level_room)
	}
}