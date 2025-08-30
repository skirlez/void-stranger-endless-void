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
		
	zoom = remember_zoom;
	calculate_zoom()
	camera_set_view_pos(view_camera[0], remember_camera_x, remember_camera_y)



	place_pack_into_room(global.pack)
	ds_map_clear(node_state_to_id_map)
	selected_thing = pack_things.nothing
	
	// exit creates this when you use it and it does persist so we Kill It
	if global.is_merged
		instance_destroy(agi("obj_darkness"))
	

		
	save_timestamp = current_time
}
if (room != global.editor_room && room != agi("rm_ev_after_erase")
		&& room != global.pack_editor_room && room != global.pack_level_room && in_pack_editor) {
	// TODO check if left pack editor in a better way
	log_info("leaving pack editor")
	ds_map_clear(node_state_to_id_map)
	ds_map_clear(node_id_to_instance_map)
	undo_actions = []
	in_pack_editor = false;
	last_nid = -1
}