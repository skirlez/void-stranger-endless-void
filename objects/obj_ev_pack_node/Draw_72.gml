if global.pack_editor.node_instance_changing_places == id {
	gpu_set_fog(true, c_black, 0, 1)
	var increase = dsin(global.editor_time) / 8 + 0.25;
	if node_type == global.pack_editor.level_node {
		var scale = (image_xscale + image_yscale) / 2 + increase / 5;
		draw_sprite_ext(agi("spr_ev_display"), 0, center_x - 112 * scale, center_y - 72 * scale, scale, scale, 0, c_white, 1)
	}
	else {
		var scale = ((image_xscale + image_yscale) / 2) * 5	
		ev_draw_cube(sprite_index, 0, x + shake_x_offset, y, scale + increase * 5, spin_h, spin_v)
	}
	gpu_set_fog(false, c_black, 0, 1)
}
if connecting_exit {
	ev_draw_pack_line(center_x, center_y, mouse_x, mouse_y)
}
for (var j = 0; j < array_length(exit_instances); j++) {
	var node = exit_instances[j];
		
	var other_center_x = node.center_x
	var other_center_y = node.center_y
			
	var number = (array_length(exit_instances) == 1) ? -1 : (j + 1)
	if (should_draw_pack_line(center_x, center_y, other_center_x, other_center_y))
		ev_draw_pack_line(center_x, center_y, other_center_x, other_center_y, number)
}	