if room != global.editor_room
	exit;
	
if (global.selected_thing == thing_placeable 
		|| (global.selected_thing == thing_multiplaceable && !global.disable_3d_cube_bs)) {
	var draw_y = 99
		
	var display_name;
	var cube_type;
	if global.disable_3d_cube_bs {
		display_name = global.held_tile_state.tile.display_name;
		cube_type = global.held_tile_state.tile.cube_type;
	}
	else if global.selected_thing == thing_placeable {
		var state = global.held_tile_state;
		display_name = state.tile.display_name;
		cube_type = state.tile.cube_type;
		if !surface_exists(spin_surface)
			spin_surface = surface_create(16, 16)
		else if surface_get_width(spin_surface) != 16 || surface_get_height(spin_surface) != 16
			surface_resize(spin_surface, 16, 16);	
		surface_set_target(spin_surface)
		draw_clear_alpha(c_black, 0)
		state.tile.draw_function(state, 0, 0, false, global.level)
		surface_reset_target()
	}
	else {
		display_name = "Multiple";
		cube_type = cube_types.uniform;
		var h = array_length(global.held_tile_array)
		var w = array_length(global.held_tile_array[0])
		if !surface_exists(spin_surface)
			spin_surface = surface_create(w * 16, h * 16)
		else if surface_get_width(spin_surface) != w * 16 || surface_get_height(spin_surface) != h * 16
			surface_resize(spin_surface, w * 16, h * 16);	
		surface_set_target(spin_surface)
		draw_clear_alpha(c_black, 0)
		for (var i = 0; i < h; i++) {
			for (var j = 0; j < w; j++) {
				var state = global.held_tile_array[i][j]
				if (state.tile == global.editor.current_empty_tile)
					continue;
				state.tile.draw_function(state, i, j, false, global.level)
			}
		}
		surface_reset_target()

	}

	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_font(global.ev_font)
		
	draw_set_color(c_black)
	draw_text_transformed(27 + 0.5, draw_y + 16, display_name, 0.5, 0.5, 0)
	draw_text_transformed(27 - 0.5, draw_y + 16, display_name, 0.5, 0.5, 0)
	draw_text_transformed(27, draw_y + 16 + 0.5, display_name, 0.5, 0.5, 0)
	draw_text_transformed(27, draw_y + 16 - 0.5, display_name, 0.5, 0.5, 0)
	draw_set_color(c_white)
	draw_text_transformed(27, draw_y + 16, display_name, 0.5, 0.5, 0)
		
			
	spin_time_h += 0.45 + random_range(-0.05, 0.05)
	spin_time_v += 0.38 + random_range(-0.05, 0.05)
	
	var spin_h = (dsin(spin_time_h) + 1) / 2;
	var spin_v = (dcos(spin_time_v) + 1) / 2;
		
		
	if stupid_sprite_i_can_only_delete_later_lest_the_cube_shall_whiten == noone {
		var sprite;
		if global.disable_3d_cube_bs {
			sprite = global.held_tile_state.tile.spr_ind
		}
		else {
			sprite = sprite_create_from_surface(spin_surface, 0, 0, 
				surface_get_width(spin_surface), surface_get_height(spin_surface), false, false, 8, 0)
				stupid_sprite_i_can_only_delete_later_lest_the_cube_shall_whiten = sprite;
		}
			
		if cube_type == cube_types.uniform
			ev_draw_cube(sprite, 0, 27, draw_y, 7, spin_h, spin_v)		
		else if cube_type == cube_types.uniform_constant
			ev_draw_cube(global.held_tile_state.tile.spr_ind, 0, 27, draw_y, 7, spin_h, spin_v)	
		else {
			var spr;
			if cube_type == cube_types.edge
				spr = sprite;
			else if cube_type == cube_types.edge_constant
				spr = global.held_tile_state.tile.spr_ind
					
			var edge_sprite = agi("spr_floor")
				
			var black_bottom_sprite = agi("spr_ev_tile_hitbox");
			ev_draw_cube_multisprite(
				[edge_sprite, edge_sprite, edge_sprite, edge_sprite, spr,
					black_bottom_sprite], [1, 1, 1, 1, 0, 0], 27, draw_y, 7, spin_h, spin_v)			
		}
			
	}
}
