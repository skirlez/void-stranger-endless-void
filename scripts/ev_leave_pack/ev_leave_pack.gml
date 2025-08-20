
function ev_leave_pack() {
	if (global.playtesting)
		room_goto(agi("rm_ev_pack_editor"))
	else
		room_goto(agi("rm_ev_pack_select"))
	global.playtesting = false;
	ds_map_clear(global.locusts_collected_this_level)
	global.editor.reset_branefuck_persistent_memory()
	
	// may exist after tis' challenge
	instance_destroy(agi("obj_cc_check"))
	instance_destroy(agi("obj_cc_medal"))
	
	ev_switch_to_user_palette()
}

function ev_pack_on_clear_level() {
	var asset = agi("obj_ev_pack_player")
	with (asset) {
		ds_map_clear(global.locusts_collected_this_level)
		var gotten_crystal = (global.token_check != 0)
		if gotten_crystal
			ds_map_set(pack_memories, current_node_state.properties.level.name, 1)
	}
}

function ev_clear_pack_level(exit_number = 0) {
	var asset = agi("obj_ev_pack_player")
	if asset == -1
		exit;
	var index = exit_number;
	with (asset) {
		if index >= array_length(current_node_state.exits)
			index = array_length(current_node_state.exits) - 1;
		if (index == -1) {
			ev_leave_pack()
			ev_notify("Cleared level with no exits!")
			return;
		}
		var new_state = current_node_state.exits[index]
		ev_pack_on_clear_level()
		move_to_node_state(new_state);
	}
}