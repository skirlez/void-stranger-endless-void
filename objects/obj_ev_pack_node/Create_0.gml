image_speed = 0.1

function set_scale_and_center_start() {
	center_x = x + center_x_offset;
	center_y = y + center_y_offset;
	scale_x_start = image_xscale
	scale_y_start = image_yscale
	center_x_offset_start = center_x_offset;
	center_y_offset_start = center_y_offset;
}
set_scale_and_center_start()

mouse_moving = false;
connecting_exit = false;
exit_instances = [];
connected_to_me = []
	
unselectable = false;
being_judged = true;
in_menu = false;
spawn_picked_up = false;
node_type = global.object_node_map[? object_index];
shake_seconds = 0;
shake_x_offset = 0;
	
spin_time_h = 0;
spin_time_v = 0;
spin_h = 0
spin_v = 0
	

line_drawer = instance_create_layer(x, y, "Lines", agi("obj_ev_pack_line_drawer"), {
	owner: id	
})


x_when_started_moving = x;
y_when_started_moving = y;
	
if !variable_instance_exists(id, "node_id") {
	global.pack_editor.last_nid++;
	node_id = global.pack_editor.last_nid
}
ds_map_set(global.pack_editor.node_id_to_instance_map, node_id, id)