if outside_view
	exit;


function draw() {
	surface_set_target(game_surface)
	if lvl.theme == level_themes.white_void
		draw_clear_alpha(c_white, 1)
	else
		draw_clear_alpha(c_black, 0)
	if lvl.theme == level_themes.universe {
		if global.is_merged {
			var universe_instance = global.editor.get_universe_instance();
			with (universe_instance) {
				if surface_exists(u_surf) {
					shader_set(agi("shader_wavy"))
					shader_set_uniform_f(t, timer)
					shader_set_uniform_f(a, 0.07)
					shader_set_uniform_f(s, 1)
					shader_set_uniform_f(f, 10)
					draw_surface(u_surf, u_x, u_y)
					shader_reset()
				}
			}
		}
	}
	var tile_mode = display_context == display_contexts.level_editor ? global.tile_mode : false
	function draw_tile_state(i, j, tile_state, preview = false) {
		tile_state.tile.draw_function(tile_state, i, j, preview, lvl, no_spoiling)
	}
	if lvl.theme != level_themes.white_void {
		draw_sprite(base_ui, 0, 0, 8 * 16)

		draw_set_font(global.ev_font)
		draw_set_halign(fa_left)
		draw_set_valign(fa_right)
		draw_set_color(c_black)


		draw_text_ext(1 * 16, 9 * 16 + 1, "VO", 0, -1)
		draw_text_ext(2 * 16, 9 * 16 + 1, "ID", 0, -1)

		draw_sprite(agi("spr_locust_idol"), 0, 5 * 16 - 8, 8 * 16 + 8)
		draw_text(5 * 16, 9 * 16 + 1, "00")

	
		if lvl.bount == -1 { 
			// idk how void stranger draws it but this is the only way i could make it align properly
			draw_text(12 * 16, 9 * 16 + 1, "V?")
			draw_text(13 * 16, 9 * 16 + 1, "?")
			draw_text(13 * 16 + 8, 9 * 16 + 1, "?")
		}
		else {
			draw_set_halign(fa_center)
			draw_set_valign(fa_middle)	
			var hundreds_digit = lvl.bount div 100;
			var tenths_digit = (lvl.bount % 100) div 10;
			var units_digit = lvl.bount % 10;
		
			draw_text(12 * 16 + 4, 9 * 16 - 8, "V")
		
			function draw_digit(pos_x, pos_y, digit) {
				// no idea why i need to do this
				var offset = (digit == 1 || digit == 3 || digit == 5 || digit == 6 || digit == 8 || digit == 9)	
				draw_text(pos_x - offset, pos_y, string(digit))
			}
		
			draw_digit(13 * 16 - 4, 9 * 16 - 8, hundreds_digit)
			draw_digit(13 * 16 + 4, 9 * 16 - 8, tenths_digit)
			draw_digit(14 * 16 - 4, 9 * 16 - 8, units_digit)
		}

		var rodsprite = (lvl.burdens[burden_types.stackrod]) ? stackrod_sprite : voidrod_sprite
		draw_sprite(rodsprite, 1, 16 * 6, 8 * 16)
		if (lvl.burdens[burden_types.swapper]) 
			draw_sprite(agi("spr_ev_swapper"), 0, 16 * 6 + 16, 8 * 16) //I'm bad at math.
		for (var i = 0; i < array_length(lvl.burdens) - 1; i++) {
			if lvl.burdens[i] {
				switch i {
					case 2:
						if global.blade_style != 2 burdens_sprite = ev_get_burden_sprite(global.blade_style)
						else burdens_sprite = agi("spr_ev_items_lev")   	
						break
					case 1:
						burdens_sprite = ev_get_burden_sprite(global.wings_style)
						break
					case 0:
						burdens_sprite = ev_get_burden_sprite(global.memory_style)
						break
					default:
						burdens_sprite = agi("spr_ev_items_lev") //Avoid displaying the diamond thing
						break
				}
				if (i != 4) 
					draw_sprite_part(burdens_sprite, 0, 16 + i * 16, 0, 16, 16, 16 * (8 + i), 8 * 16)		
			}
		}
	}
	
	// this array is made static, so it is reused between all instances, and its contents are never cleaned,
	// but it has a limit it can expand to, so i think this will improve performance
	static those_who_offset = [];
	var last_offset_index = -1;
	
	for (var i = 0; i < 9; i++)	{
		for (var j = 0; j < 14; j++) {
			if i != 8 {
				var tile_state = lvl.tiles[i][j]
				draw_tile_state(i, j, tile_state)
			}
			if lvl.objects[i][j].tile.has_offset() {
				var object_state = lvl.objects[i][j];
				if object_state.properties.ofx == 0 && object_state.properties.ofy == 0
					continue;
				last_offset_index++;
				those_who_offset[last_offset_index] = {
					pos_i : i + object_state.properties.ofy,
					pos_j : j + object_state.properties.ofx,
					state : object_state
				};
			}
		}
	}
	
	var alpha = tile_mode ? 0.4 : 1;
	draw_set_alpha(alpha);
	
	for (var i = 0; i <= last_offset_index; i++) {
		var struct = those_who_offset[i];
		draw_tile_state(struct.pos_i, struct.pos_j, struct.state)
	}
	
	
	for (var i = 0; i < 9; i++)	{
		for (var j = 0; j < 14; j++) {
			var object_state = lvl.objects[i][j]
			if object_state.tile.has_offset() && (object_state.properties.ofx != 0 || object_state.properties.ofy != 0) {
				// when viewing in a no spoiling context, we only want the offset projection to be shown
				// skip drawing real position
				if no_spoiling 
					continue;
				draw_set_alpha(alpha * 0.5)
				draw_tile_state(i, j, object_state)
				draw_set_alpha(alpha)
			}
			else
				draw_tile_state(i, j, object_state)
		}
	}
	
	draw_set_alpha(1)


	if (display_context == display_contexts.level_editor && ev_is_mouse_on_me()) {
		var tile_j = floor((mouse_x - x) / (16 * image_xscale))
		var tile_i = floor((mouse_y - y) / (16 * image_yscale))

		if dragging {
			var small_tile_i = drag_box_i
			var small_tile_j = drag_box_j
		
			if (tile_i < drag_box_i) {
				small_tile_i = tile_i
				tile_i = drag_box_i
			}
			if (tile_j < drag_box_j) {
				small_tile_j = tile_j
				tile_j = drag_box_j
			}
		
			draw_sprite_ext(global.selection_sprite, 0, 
				small_tile_j * 16, small_tile_i * 16, 
				tile_j - small_tile_j + 1, tile_i - small_tile_i + 1,
				0, c_white, 1)
		}
	
		else if global.selected_thing == thing_placeable 
				&& global.held_tile_state.tile != global.editor.object_empty {
			var alpha = ((dsin(global.editor_time * 3) / 4) + 0.75);
		
			if global.held_tile_state.tile.has_offset() {
				draw_set_alpha(alpha / 2)
				draw_tile_state(tile_i, tile_j, global.held_tile_state, true)
				draw_set_alpha(alpha)
				draw_tile_state(
					tile_i + global.held_tile_state.properties.ofy,
					tile_j + global.held_tile_state.properties.ofx,
					global.held_tile_state, true)
			}
			else {
				draw_set_alpha(alpha)
				draw_tile_state(tile_i, tile_j, global.held_tile_state, true)
			}
		
			draw_set_alpha(1)
		}
		else if global.selected_thing == thing_multiplaceable {
			draw_set_alpha((dsin(global.editor_time * 3) / 4) + 0.75)
			for (var i = 0; i < array_length(global.held_tile_array); i++) {
				for (var j = 0; j < array_length(global.held_tile_array[i]); j++) {
					var tile_state = global.held_tile_array[i][j]
					if (tile_state.tile == global.editor.current_empty_tile)
						continue;
					var new_tile_i = tile_i + i;
					if new_tile_i >= 9
						continue;
					var new_tile_j = tile_j + j
					if new_tile_j >= 14
						continue;
					draw_tile_state(tile_i + i, tile_j + j, tile_state, false)
				}
			}
			draw_set_alpha(1)
		}
	}
	surface_reset_target()
}

function draw_exit_numbers() {
	if display_context == display_contexts.pack_editor {
		if global.pack_editor.selected_thing = pack_things.hammer 
		&& array_length(owner_node.exit_instances) > 0 {
			var exit_number = 1;
			draw_set_font(global.ev_font)
			draw_set_halign(fa_center)
			draw_set_valign(fa_middle)
			
			for (var i = 0; i < 9; i++)	{
				for (var j = 0; j < 14; j++) {
					var color;
					if exit_number > array_length(owner_node.exit_instances)
						color = c_ltgray
					else
						color = c_white
					 
					var is_tile_exit = (lvl.tiles[i][j].tile == global.editor.tile_exit)
					var is_object_exit = (lvl.objects[i][j].tile == global.editor.object_secret_exit)
					
					var text;
					if is_tile_exit && is_object_exit {
						text = string(exit_number) + "+" + string(exit_number+1);
					}
					else if is_tile_exit || is_object_exit {
						text = string(exit_number)
					}
					else
						text = ""

					if text != "" {
						function draw_exit_number(pos_x, pos_y, text) {
							draw_text_transformed(pos_x, pos_y, text, image_xscale, image_yscale, 0)
						}
						var pos_x = x + (j * 16 + 8) * image_xscale;
						var pos_y = y + (i * 16 + 8) * image_yscale;
						var unit_x = image_xscale;
						var unit_y = image_yscale;
						draw_set_color(c_black)
						draw_exit_number(pos_x + unit_x, pos_y, text)
						draw_exit_number(pos_x - unit_x, pos_y, text)
						draw_exit_number(pos_x, pos_y + unit_y, text)
						draw_exit_number(pos_x, pos_y - unit_y, text)
						draw_set_color(color)
						draw_exit_number(pos_x, pos_y, text)
					}
					exit_number += is_tile_exit + is_object_exit
				}
			}
		}
	}

}

if !surface_exists(game_surface) {
	game_surface = surface_create(224, 144);
	draw();
}

if (display_context != display_contexts.pack_editor)
	draw();
else if global.is_merged {
	if !outside_view && global.pack_editor.zoom <= 2 {
		draw();
	}

}


var draw_x = x;

gpu_set_blendenable(false)
draw_surface_ext(game_surface, draw_x, y, image_xscale, image_yscale, 0, c_white, 1)
gpu_set_blendenable(true)
draw_exit_numbers()
draw_sprite_ext(border_sprite, 0, draw_x, y, image_xscale, image_yscale, 0, c_white, 1)


if brand != 0 {
	if !surface_exists(brand_surface) || cached_author_brand != lvl.author_brand {
		brand_surface = surface_create(8, 8)
		surface_set_target(brand_surface)
		draw_clear_alpha(c_black, 1)
		
		draw_set_color(c_grey)
		ev_draw_rectangle(0, 0, 7, 7, true)
		
		draw_set_color(c_white)
		
		ev_draw_brand(1, 1, brand)
		
		surface_reset_target()
		cached_author_brand = lvl.author_brand
	}	
	var size = 1;
	draw_surface_ext(brand_surface, x + sprite_width - 4 * size,
		y + sprite_height - 4 * size, size, size, 0, c_white, image_alpha)
}



if name != "" {
	if (!surface_exists(name_surface)) {
		var txt = name;
		name_surface = surface_create((string_width(txt) + 2), (string_height(txt) + 2));	
		surface_set_target(name_surface)
		draw_clear_alpha(c_black, 0)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_color(c_white)
		draw_set_font(global.ev_font)
		draw_text_shadow(2, 1, txt, c_black)
		surface_reset_target()
	}


	
	draw_set_font(global.ev_font)
	var size = 1
	var text_width = string_width(name);
	if (text_width > sprite_width) { 
		size = sprite_width / text_width
	}
	draw_surface_ext(name_surface, x + sprite_width / 2 - (surface_get_width(name_surface) / 2) * size,
		y + sprite_height + 2, size, size, 0, c_white, image_alpha)
}

if draw_beaten == 1 {
	draw_sprite(agi("spr_ev_checkmark"), 0, x + sprite_width - 9, y + sprite_height)
}
else if draw_beaten == 2 {
	var time = (global.editor_time / 2) % 80
	var spr = agi("spr_ev_memory_collected")
	if time > sprite_get_number(spr) - 1
		time = 0;
	draw_sprite(spr, time, x + sprite_width - 9, y + sprite_height)
	
}

