ev_set_play_variables()
ev_prepare_level_burdens()

current_node_state = noone;
brand_node_states = noone;

// keeps track of levels visited in this pack
// is a map of level names
// used as a hashset (only checking if entries exist)
visited_levels = ds_map_create();

// keeps track of memories collected in this pack
// is a map of level names
// used as a hashset (only checking if entries exist)
pack_memories = ds_map_create();

in_brand_room = false;

// total amount of miliseconds in this pack
play_time = 0

// timestamp since the start of this session
start_time = current_time

total_locusts_collected = 0

function move_to_root_state() {
	move_to_node_state(global.pack.starting_node_states[0])
}

function move_to_node_state(state) {
	var failsafe = 200;
	var potential_next_state = state;
	do {
		current_node_state = potential_next_state;
		potential_next_state = current_node_state.node.play_evaluate_immediate(current_node_state);
		failsafe--;
		if failsafe <= 0 {
			ev_notify("Loop detected! Exiting pack")	
			ev_leave_pack()
			return;
		}
	} until (potential_next_state < 0)
	
	if potential_next_state == node_return_status.need_exits {
		ev_notify("Reached node with no exits!")	
		ev_leave_pack()
	}
	else if potential_next_state == node_return_status.not_immediate {
		if current_node_state.node == global.pack_editor.level_node {
			ds_map_set(visited_levels, current_node_state.properties.level.name, 1)
			if !global.playtesting && !is_first_level
				save_pack_progress(current_node_state.properties.level.name)
		}

		room_restart();
	}
	else {
		ev_notify("????")
		ev_leave_pack()
	}
}
function end_pack() {
	ev_leave_pack()	
}

function on_room_create() {
	log_info("Pack player running on_room_create")
	if brand_node_states == noone {
		log_info($"Initializing brand nodes")
		brand_node_states = [];
		for (var i = 0; i < array_length(global.pack.starting_node_states); i++) {
			var state = global.pack.starting_node_states[i];
			if (state.node == global.pack_editor.brand_node) {
				array_push(brand_node_states, state)
			}
		}
		log_info($"We have {array_length(brand_node_states)} brand nodes")
	}
	if current_node_state == noone {
		log_info("Choosing starting node")
		if global.playtesting {
			ev_prepare_level_burdens(global.pack_playtest_parameters.burdens);
			ds_grid_set(agi("obj_inventory").ds_player_info, 1, 1, global.pack_playtest_parameters.locust_count)
			
			var node_id = global.pack_playtest_parameters.node_id;
			var node_states = ds_map_keys_to_array_fix(global.pack_editor.node_state_to_id_map);
			for (var i = 0; i < array_length(node_states); i++) {
				if (ds_map_find_value(global.pack_editor.node_state_to_id_map, node_states[i]) == node_id) {
					move_to_node_state(node_states[i])
					break;
				}
			}
		}
		else {
			var first_state = noone;
			var save = load_pack_progress(global.pack);
			if save == noone {
				log_info("No save, choosing root")
				first_state = global.pack.starting_node_states[0];
			}
			else {
				first_state = apply_pack_save(save)
				
			}
			move_to_node_state(first_state)
		}
	}
	else {
		current_node_state.node.play_evaluate(current_node_state);
		
	}
	
	alarm[0] = 1
}

// checked and changed at level_node.play_evaluate
is_first_level = !global.playtesting;
is_brand_room = false;

// called at level_node.play_evaluate
function evaluate_brand_room() {
	in_brand_room = is_level_brand_room(global.level)
	if in_brand_room {
		brand_secret_exit = instance_create_layer(-100, -100, "Instances",
			agi("obj_na_secret_exit"))
	}
}
// instance we move around depending on if this is a brand room
brand_secret_exit = noone;

dust_emit_counter = 0;
dust_emit_limit = 0;

