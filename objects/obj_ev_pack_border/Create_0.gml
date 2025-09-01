function toggle() {
	visible = !visible
	objects = ["obj_ev_pack_hammer", "obj_ev_pack_wrench", "obj_ev_pack_add_level_button", 
		"obj_ev_pack_node_button", "obj_ev_pack_settings_button", "obj_ev_pack_editor_play_button",
			"obj_ev_pack_void_radio_button", "obj_ev_pack_placechanger", "obj_ev_pack_undo_button"]
	for (var i = 0; i < array_length(objects); i++) {
		with (agi(objects[i])) {
			visible = other.visible
		}
	}
}