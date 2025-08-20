if (room == global.pack_editor_room) {
	if !in_pack_editor {
		remember_camera_x = 250;
		remember_camera_y = 993;
		remember_zoom = 0;
		in_pack_editor = true;
		
	}

	if global.void_radio_on
		ev_play_void_radio()
	else
		ev_stop_music()
	camera_set_view_pos(view_camera[0], remember_camera_x, remember_camera_y)
	zoom = remember_zoom;	
	calculate_zoom()
	
	place_pack_into_room(global.pack)
	ds_map_clear(node_state_to_id_map)
	selected_thing = pack_things.nothing
	
	// exit creates this when you use it and it does persist so we Kill It
	if global.is_merged
		instance_destroy(agi("obj_darkness"))
		
	save_timestamp = current_time
}