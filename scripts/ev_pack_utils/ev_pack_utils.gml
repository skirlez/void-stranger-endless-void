function ev_draw_pack_line(x1, y1, x2, y2, number = 0) {
	draw_set_color(c_black)
	draw_line_width(x1, y1,	x2, y2, 2)
	static arrow_sprite = agi("spr_ev_pack_arrow")
	
	var t = get_pack_line_arrow_progress();
	var pos_x = lerp(x1, x2, t)
	var pos_y = lerp(y1, y2, t)


	// makes the spin happen twice
	var t2 = t % 0.5;
	
	var angle_target = point_direction(x1, y1, x2, y2);
	var angle_start = point_direction(x1, y1, x2, y2) + 360;

	// (1-1/exp(x)) goes from 0 to 1 in a nice curve
	var angle = lerp(angle_start, angle_target, 1 - (1 / exp(t2 * 12)))


	// roots of sin x give us a sort of "rectangular" curve from 0-pi, which is what we want -
	// very quickly going to a near 1 value at the start and very quickly dropping off at the end
	// t is between 0-1 so we multiply by pi
	var scale = power(sin(t * pi), 1/3)
	
	draw_sprite_ext(arrow_sprite, 0, pos_x + 0.5, pos_y + 0.5, scale, scale, angle, c_white, 1)
	if number > 0 {
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_set_font(global.ev_font)
		draw_set_color(c_white)
		var number_t = get_pack_line_number_progress()
		var number_pos_x = lerp(x1, x2, number_t)
		var number_pos_y = lerp(y1, y2, number_t)
		draw_text_shadow(number_pos_x, number_pos_y, string(number), c_black);
	}
	/*
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_color(c_white)
	draw_text_ext_transformed(
		pos_x + 9 * dcos(angle_target + 90), 
		pos_y - 9 * dsin(angle_target + 90) - 4, "1", 0, 300, scale * 0.5, scale * 0.5, 0)
	*/
}

function get_pack_line_arrow_progress() {
	return (global.editor_time % 200) / 200;	
}
function get_pack_line_number_progress() {
	var t = get_pack_line_arrow_progress() - 0.15;
	if t < 0
		t += 1;
	return t;
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




function get_nodes_connected_to_node(target) {
	function is_connected(target) {
		for (var i = 0; i < array_length(exit_instances); i++) {
			if (exit_instances[i] == target)
				return true;
		}
		return false;
	}
	var list = []
	with (global.node_object) {
		if is_connected(target)
			array_push(list, id)
	}
	return list;
}

/*
Removes all connections to a node and returns the list of node instances from which it disconnected.
*/
function remove_connections_to_node(target) {
	function disconnect_from_node_instance(target) {
		for (var i = 0; i < array_length(exit_instances); i++) {
			if (exit_instances[i] == target) {
				create_falling_arrow_and_number(id, target, i, array_length(exit_instances));
				array_delete(exit_instances, i, 1)
				return true;
			}
		}
		return false;
	}
	var list = []
	with (global.node_object) {
		if disconnect_from_node_instance(target)
			array_push(list, id)
	}
	return list;
}

function create_pack_parameters(burdens = [false, false, false, false, false],
		locust_count = 0, 
		tis = false, 
		node_id = -1) {
	return { burdens : burdens, locust_count : locust_count, tis : tis, node_id : node_id }	
}
