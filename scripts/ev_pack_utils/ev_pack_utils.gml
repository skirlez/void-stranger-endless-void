/*
function line_intersects_horizontal(x1, y1, x2, y2, x3, y3, line_length) {
	var slope = (y2 - y1) / (x2 - x1)
	var ix = (y3 - y1) / slope + x1
	return x3 <= ix && ix <= x3
}
function line_intersects_vertical(x1, y1, x2, y2, x3, y3, line_length) {
	var slope = (y2 - y1) / (x2 - x1)
	var iy = slope * (x3 - x1) + y1
	return y3 <= iy && iy <= y3 + line_length
}
*/

function should_draw_pack_line(x1, y1, x2, y2) {
	static obj = agi("obj_camera_hitbox")
	return collision_line(x1, y1, x2, y2, obj, false, false)
}



function ev_draw_pack_line(x1, y1, x2, y2, number = 0) {
	draw_set_color(c_black)
	draw_line_width(x1, y1,	x2, y2, 2)
	static arrow_sprite = agi("spr_ev_pack_arrow")
	
	var t = global.pack_arrow_progress
	var pos_x = lerp(x1, x2, t)
	var pos_y = lerp(y1, y2, t)


	// makes the spin happen twice
	var t2 = t % 0.5;
	
	var scale = global.pack_arrow_scale
	
	var angle_target = point_direction(x1, y1, x2, y2);
	var angle_start = point_direction(x1, y1, x2, y2) + 360;

	// (1-1/exp(x)) goes from 0 to 1 in a nice curve
	var angle = lerp(angle_start, angle_target, 1 - (1 / exp(t2 * 12)))



	
	draw_sprite_ext(arrow_sprite, 0, pos_x + 0.5, pos_y + 0.5, scale, scale, angle, c_white, 1)
	if number > 0 {
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_set_font(global.ev_shadow_font)
		draw_set_color(c_white)
		var number_t = global.pack_number_progress
		var number_scale = global.pack_number_scale
		var number_pos_x = lerp(x1, x2, number_t)
		var number_pos_y = lerp(y1, y2, number_t)
		draw_text_transformed(number_pos_x, number_pos_y, string(number), number_scale, number_scale, 0)
	}

}



function get_all_level_node_instances() {
	var node_instances = get_all_node_instances();
	var level_node_instances = []
	for (var i = 0; i < array_length(node_instances); i++) {
		if node_instances[i].node_type == global.pack_editor.level_node
			array_push(level_node_instances, node_instances[i])	
	}
	return level_node_instances
}

function get_all_node_instances() {
	var node_instances = []
	static nodes_layer = layer_get_id("Nodes")
	var node_instance_elements = layer_get_all_elements(nodes_layer)
	for (var i = 0; i < array_length(node_instance_elements); i++) {
		array_push(node_instances, layer_instance_get_instance(node_instance_elements[i]))	
	}
	return node_instances;
	
}
function destroy_all_node_instances() {
	var node_instances = get_all_node_instances();
	for (var i = 0; i < array_length(node_instances); i++) {
		instance_destroy(node_instances[i])
	}
}


// checks if any other nodes has this level's name, and if they do,
// renames the level by adding _number. or if there's already _number at the end,
// increases the number.
function try_level_name_and_rename(lvl, level_nodes) {
	for (var i = 0; i < array_length(level_nodes); i++) {
		var other_lvl = level_nodes[i].properties.level;
		if (other_lvl == lvl)
			continue;
		if (other_lvl.name == lvl.name) {
			var arr = ev_string_split(other_lvl.name, "_")
			if array_length(arr) == 0 {
				lvl.name += "_1"
				try_level_name_and_rename(lvl, level_nodes)
				return;
			}
			else {
				var last = array_length(arr) - 1
				if string_is_uint(arr[last]) {
					var num = int64(arr[last])
					lvl.name = ""
					for (var i = 0; i < last; i++) {
						lvl.name += arr[i] + "_"
					}
					lvl.name += string(num + 1)
					try_level_name_and_rename(lvl, level_nodes)
					return;
				}
				else {
					lvl.name += "_1"
					try_level_name_and_rename(lvl, level_nodes)
					return;
				}
			}
		}
	}
}





/*
Removes all connections to a node and returns the list of node instances from which it disconnected.
*/
function remove_connections_to_node(target) {
	var list = copy_array(target.connected_to_me)
	for (var i = 0; i < array_length(list); i++) {
		var inst = list[i]
		var index = disconnect_node_instances(inst, target)
		create_falling_arrow_and_number(inst, target, index, array_length(inst.exit_instances) + 1);
	}
	return list;
}

function connect_node_instances(from, to) {
	array_push(from.exit_instances, to);
	array_push(to.connected_to_me, from);
	from.line_drawer.update()
}
function disconnect_node_instances(from, to) {
	var to_index = ev_array_get_index(from.exit_instances, to)
	var from_index = ev_array_get_index(to.connected_to_me, from)
	array_delete(from.exit_instances, to_index, 1)
	array_delete(to.connected_to_me, from_index, 1)
	from.line_drawer.update()
	return to_index;
}


function create_pack_parameters(burdens = [false, false, false, false, false],
		locust_count = 0, 
		tis = false, 
		node_id = -1) {
	return { burdens : burdens, locust_count : locust_count, tis : tis, node_id : node_id }	
}
function connect_node_states(from, to) {
	array_push(from.exits, to);
	array_push(to.connected_to_me, from);
}
function find_music_for_node_state(state) {
	while (array_length(state.connected_to_me) == 1) {
		if state.connected_to_me[0].node == global.pack_editor.music_node {
			var track = agi(state.connected_to_me[0].properties.music);
			return track;
		}
		state = state.connected_to_me[0];	
	}
	if array_length(state.connected_to_me) == 0 {
		return noone;	
	}
	for (var i = 0; i < array_length(state.connected_to_me); i++) {
		if state.connected_to_me[i].node == global.pack_editor.music_node {
			var track = agi(state.connected_to_me[i].properties.music);
			return track;
		}
	}
	return noone;
}

function do_placechanger_explosion_particles(from, to) {
	static particle = agi("obj_ev_placechanger_particle")
	var offset = random_range(-5, 5)
	repeat (irandom_range(8, 10)) {
		var angle = point_direction(from.center_x, from.center_y, to.center_x, to.center_y) + random_range(-40, 40) + offset
		instance_create_layer(to.center_x, to.center_y, "Effects", particle, {
			hsp : random_range(3, 6) * dcos(angle),
			vsp : -random_range(3, 6) * dsin(angle)
		})
	}	
}
function do_placechanger_line_particles(one, two) {
	var current_x = one.center_x
	var current_y = one.center_y
	var step_x = (two.center_x - one.center_x) / 15
	var step_y = (two.center_y - one.center_y) / 15
	repeat (15) {
		var angle = random_range(0, 360)
		instance_create_layer(current_x, current_y, "Effects", agi("obj_ev_placechanger_particle"), {
			hsp : 2 * dcos(angle),
			vsp : -2 * dsin(angle)
		})
		current_x += step_x;
		current_y += step_y;
	}
}