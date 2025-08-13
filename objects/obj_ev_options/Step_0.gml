event_inherited();

var camera_y = lerp(camera_get_view_y(view_camera[0]), current_page * 144, 0.3)
camera_set_view_pos(view_camera[0], 0, camera_y)

for (var i = 0; i < array_length(those_who_special); i++) {
	those_who_special[i].y = camera_y + those_who_special[i].ystart	
}


ev_window_sort_textbox_depths(textbox_depth)