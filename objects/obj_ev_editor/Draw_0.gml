draw_set_color(c_white)
if (room == global.editor_room) {
	
	if (global.selected_thing == thing_placeable) && global.mouse_layer == 0 {
		var draw_y = 99
		
		var state = global.display_object.held_tile_state;
		if !surface_exists(spin_surface)
			spin_surface = surface_create(16, 16)
		surface_set_target(spin_surface)
		draw_clear_alpha(c_black, 0)
		state.tile.draw_function(state, 0, 0, false, global.level)
		surface_reset_target()

		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_set_font(global.ev_font)
		
		draw_set_color(c_black)
		draw_text_transformed(27 + 0.5, draw_y + 16, state.tile.display_name, 0.5, 0.5, 0)
		draw_text_transformed(27 - 0.5, draw_y + 16, state.tile.display_name, 0.5, 0.5, 0)
		draw_text_transformed(27, draw_y + 16 + 0.5, state.tile.display_name, 0.5, 0.5, 0)
		draw_text_transformed(27, draw_y + 16 - 0.5, state.tile.display_name, 0.5, 0.5, 0)
		draw_set_color(c_white)
		draw_text_transformed(27, draw_y + 16, state.tile.display_name, 0.5, 0.5, 0)
		
			
		spin_time_h += 0.45 + random_range(-0.05, 0.05)
		spin_time_v += 0.38 + random_range(-0.05, 0.05)
	
		var spin_h = (dsin(spin_time_h) + 1) / 2;
		var spin_v = (dcos(spin_time_v) + 1) / 2;
		
		
		if stupid_sprite_i_can_only_delete_later_lest_the_cube_shall_whiten == noone {
			var sprite;
			if global.disable_3d_cube_bs {
				sprite = state.tile.spr_ind
			}
			else {
				sprite = sprite_create_from_surface(spin_surface, 0, 0, 16, 16, false, false, 8, 0)
				stupid_sprite_i_can_only_delete_later_lest_the_cube_shall_whiten = sprite;
			}
			
			if state.tile.cube_type == cube_types.uniform
				ev_draw_cube(sprite, 0, 27, draw_y, 7, spin_h, spin_v)		
			else if state.tile.cube_type == cube_types.uniform_constant
				ev_draw_cube(state.tile.spr_ind, 0, 27, draw_y, 7, spin_h, spin_v)	
			else {
				
				var spr;
				if state.tile.cube_type == cube_types.edge
					spr = sprite;
				else if state.tile.cube_type == cube_types.edge_constant
					spr = state.tile.spr_ind
					
				edge_sprite = agi("spr_floor")
				
				var black_bottom_sprite = agi("spr_ev_tile_hitbox");
				ev_draw_cube_multisprite(
					[edge_sprite, edge_sprite, edge_sprite, edge_sprite, spr,
						black_bottom_sprite], [1, 1, 1, 1, 0, 0], 27, draw_y, 7, spin_h, spin_v)			
			}
			
		}
		
		
		

		
	}
	if (global.selected_thing == thing_multiplaceable) {
		// do something later maybe
	}
}

if global.erasing != -1 {
	if !surface_exists(erasing_surface)
		erasing_surface = surface_create(224, 144)
	surface_set_target(erasing_surface)
	draw_clear(c_black)
	draw_set_color(c_white)
	gpu_set_blendmode(bm_subtract);	
	var rand_x = irandom_range(-3, 3)
	var rand_y = irandom_range(-3, 3)
	var radius = sqrt(global.erasing) * 10;
	draw_circle(112 + rand_x, 72 + rand_y, radius, false)
	gpu_set_blendmode(bm_normal);
	
	draw_set_alpha(1 - min(1, (sqrt(global.erasing) * 10) / 350))
	draw_circle(112 + rand_x, 72 + rand_y, radius, false)
	draw_set_alpha(1)
	
	surface_reset_target()
	draw_surface(erasing_surface, 0, 0)
}

if (edit_transition != -1 || play_pack_transition_time != -1) {
	draw_clear(c_black)	
}

if (room == agi("rm_ev_menu")) {
	draw_set_color(c_white)
	draw_set_font(global.ev_font)
	draw_set_halign(fa_left)
	draw_set_valign(fa_middle)
	
	
	if global.there_is_a_newer_version
		draw_text_transformed(6, 72 + 62, "THERE IS A NEWER VERSION!!!\n" + $"You are on {global.ev_version}, latest is {global.newest_version}", 0.5, 0.5, 0)
	else
		draw_text_transformed(6, 72 + 65, global.ev_version, 0.5, 0.5, 0)
}
else if (room == global.startup_room) {
	draw_set_color(c_white)
	draw_set_font(global.ev_font)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text_transformed(112, 72, $"Communicating with server...\nTasks left: {startup_actions_count}", 1, 1, 0)
}

