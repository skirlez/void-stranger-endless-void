switch (display_context) {
	case display_contexts.level_editor:
		if (ev_is_mouse_on_me()) {

			var tile_j = floor((mouse_x - x) / (16 * image_xscale))
			var tile_i = floor((mouse_y - y) / (16 * image_yscale))
	
			if ev_mouse_held() && !dragging {
				if (last_clicked_i != tile_i || last_clicked_j != tile_j) {
		
					if painting = false {
						if (global.selected_thing != thing_nothing && global.selected_thing != thing_picker) // these do not change level state
							global.editor.add_undo()
						painting = true;
					}
		
					handle_click_before(tile_i, tile_j)
					handle_click(tile_i, tile_j)
					handle_click_after(tile_i, tile_j)
					last_clicked_i = tile_i;
					last_clicked_j = tile_j;
				}
			}
			else if painting == true
				painting = false;	
		
			if ev_mouse_released() {
				last_clicked_i = -1;
				last_clicked_j = -1;
			}
	
	
	 

			if (!dragging && mouse_check_button_pressed(mb_right)
					&& !(global.selected_thing == thing_placeable 
						&& global.held_tile_state != noone 
						&& global.held_tile_state.tile.flags & tile_flags.only_one)
					&& global.selected_thing != thing_multiplaceable)
					&& global.selected_thing != thing_nothing {
				dragging = true
				drag_box_i = tile_i
				drag_box_j = tile_j
				audio_play_sound(drag_sound, 10, false, 1, 0, 0.6)
			}
			else if dragging { 

		
				if (last_i != tile_i || last_j != tile_j) {
					audio_stop_sound(drag_sound)
					var pitch_i = abs(tile_i - drag_box_i) / 16 + 1
					var pitch_j = abs(tile_j - drag_box_j) / 26 + 1
					audio_play_sound(drag_sound, 10, false, 1, 0, pitch_i * pitch_j)	
				}
		
				if mouse_check_button_released(mb_right) {
					small_tile_i = drag_box_i
					small_tile_j = drag_box_j
		
					if (tile_i < drag_box_i) {
						small_tile_i = tile_i
						tile_i = drag_box_i
					}
					if (tile_j < drag_box_j) {
						small_tile_j = tile_j
						tile_j = drag_box_j
					}
			
					function region_has_tiles(from_i, from_j, to_i, to_j) {
						for (var i = from_i; i <= to_i; i++) {
							for (var j = from_j; j <= to_j; j++) {
								if (lvl.tiles[i][j].tile != global.editor.tile_pit)
									return true;
							}
						}	
						return false;
					}
			
					function region_has_objects(from_i, from_j, to_i, to_j) {
						for (var i = from_i; i <= to_i; i++) {
							for (var j = from_j; j <= to_j; j++) {
								if (lvl.objects[i][j].tile != global.editor.object_empty)
									return true;
							}
						}	
						return false;
					}
					if (!global.tile_mode 
							&& (global.selected_thing == thing_picker
								|| global.selected_thing == thing_plucker
								|| global.selected_thing == thing_eraser)
							&& !region_has_objects(small_tile_i, small_tile_j, tile_i, tile_j)
							&& region_has_tiles(small_tile_i, small_tile_j, tile_i, tile_j)) 
					{
						global.editor.switch_tile_mode(true)
					}
					
					
					global.editor.add_undo()
					handle_click_before(tile_i, tile_j)
			
					for (var i = small_tile_i; i <= tile_i; i++) {
						for (var j = small_tile_j; j <= tile_j; j++)
							handle_click(i, j)
					}
			
					handle_click_after(tile_i, tile_j)
			
					dragging = false		
					drag_box_i = -1
					drag_box_j = -1
				}
	

			}
	
			// we need to check if ctrl is held if Z is also the action key,
			// as to avoid undoing and at the same time performing the zed function
			var ctrl_held = (ev_get_action_key() == ord("Z") && keyboard_check(vk_control)) 
	
			if global.selected_thing == thing_placeable 
				&& ev_is_action_pressed()
				&& global.held_tile_state.tile.zed_function != noone 
				&& !ctrl_held
			{
				audio_play_sound(zed_sound, 10, false)
				global.held_tile_state.tile.zed_function(global.held_tile_state)
			}
	
			last_i = tile_i;
			last_j = tile_j;
		}
		else {
			painting = false;
			last_clicked_i = -1;
			last_clicked_j = -1;
			last_i = -1;
			last_j = -1;
			if dragging == true && !ev_mouse_right_held() {
				dragging = false
				drag_box_i = -1
				drag_box_j = -1
			}
		}
		break;
	case display_contexts.level_select:
	case display_contexts.level_select_pack:
		break;
	case display_contexts.pack_editor:
		var cam_x = camera_get_view_x(view_camera[0])
		var cam_width = camera_get_view_width(view_camera[0])
		var cam_y = camera_get_view_y(view_camera[0])
		var cam_height = camera_get_view_height(view_camera[0])
		outside_view = 
			x < cam_x - 224 * image_xscale
			|| x > cam_x + cam_width + 224 * image_xscale
			|| y < cam_y - 144 * image_yscale
			|| y > cam_y + cam_height + 144 * image_yscale
		if outside_view
			break;
		break;
}
