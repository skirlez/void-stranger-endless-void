// debug
//draw_self()

/*
var cam_x = camera_get_view_x(view_camera[0])
var cam_y = camera_get_view_y(view_camera[0])
var cam_width = camera_get_view_width(view_camera[0])
var cam_height = camera_get_view_height(view_camera[0])
	
if rectangle_in_rectangle(cam_x, cam_y, cam_x + cam_width, cam_y + cam_height, box_top, box_top, box_right, box_bottom) == 0
	exit;
*/
for (var j = 0; j < array_length(exit_instances); j++) {
	var node = exit_instances[j];
		
	var other_center_x = node.center_x
	var other_center_y = node.center_y
			
	var number = (array_length(exit_instances) == 1) ? -1 : (j + 1)
	//if (should_draw_pack_line(center_x, center_y, other_center_x, other_center_y))
		ev_draw_pack_line(center_x, center_y, other_center_x, other_center_y, number)
}
