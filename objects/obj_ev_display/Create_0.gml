// Object purpose: Display a level struct, and do different things depending on the display_context.


last_clicked_i = -1;
last_clicked_j = -1;
last_i = -1;
last_j = -1;
drag_box_i = -1
drag_box_j = -1
dragging = false

painting = false;

if display_context == display_contexts.level_editor {

	place_sound = agi("snd_ev_place")
	drag_sound = agi("snd_ev_drag")
	erase_sound = agi("snd_ev_erase")
	zed_sound = agi("snd_ev_zed")
	pluck_sound = agi("snd_ev_pluck")
	pick_sound = agi("snd_ev_pick")

}

function switch_held_tile(tile_state) {
	global.held_tile_state = tile_state
	global.selected_thing_time = 0
}




function place_placeable(tile_i, tile_j, new_tile, properties = global.empty_struct, run_place_func = true) {
	var arr = global.editor.get_current_placeables();
	var tile_state = arr[tile_i][tile_j]
			
	if (tile_state.tile != new_tile) {
		if (tile_state.tile.flags & tile_flags.unremovable)
			return;

		//audio_play_sound(snd_reveal, 10, false)
	}
	
	if (new_tile.flags & tile_flags.only_one) {
		for (var i = 0; i < 9; i++) {
			for (var j = 0; j < 14; j++) {
				if arr[i][j].tile == new_tile
					arr[@ i][j] = new tile_with_state(global.editor.current_empty_tile)
						
			}
		}
	}
	
	tile_state = new tile_with_state(new_tile, properties)
	if (run_place_func)
		tile_state = new_tile.place_function(tile_state, tile_i, tile_j, lvl);
	arr[@ tile_i][tile_j] = tile_state;
}

// This function runs first when handling a right click release (drag), or left click
function handle_click_before(tile_i, tile_j) {
	var tile_state = global.editor.get_current_placeables()[tile_i][tile_j];
	switch (global.selected_thing) {
		case thing_plucker:
		case thing_picker:
			if dragging {
				var height = tile_i - small_tile_i + 1;
				var width = tile_j - small_tile_j + 1;
				global.held_tile_offset = [small_tile_i, small_tile_j]
				global.held_tile_array = array_create(height)
				
				
				for (var i = 0; i < array_length(global.held_tile_array); i++) {
					global.held_tile_array[i] = array_create(width, new tile_with_state(global.editor.current_empty_tile))	
				}
			}
			return;
		case thing_eraser:
			if tile_state.tile != global.editor.current_empty_tile || dragging
				audio_play_sound(erase_sound, 10, false, 1, 0, random_range(0.7, 1))
			return;

		case thing_placeable:
			if tile_state.tile != global.held_tile_state.tile || dragging {
				audio_stop_sound(place_sound)
				audio_play_sound(place_sound, 10, false, 1, 0, random_range(0.8, 1.2))	
			}
			else
				audio_play_sound(drag_sound, 10, false, 1.2, 0, 3.5)	
			
			return;
		case thing_multiplaceable:
			audio_stop_sound(place_sound)
			audio_play_sound(place_sound, 10, false, 1, 0, 0.7)
			return;
		default:
			return;
	}
}

// This function runs second when handling a right click release (drag), or left click.
// it runs for every single tile affected by the action, unlike the others 
// (meaning, per tile for each tile dragged, or just 1 if left clicked)
function handle_click(tile_i, tile_j) {
	switch (global.selected_thing) {
		case thing_picker:
		case thing_plucker: // nearly the same, might as well lump them together and check when needed..
			if dragging {
				var tile_state = global.editor.get_current_placeables()[tile_i][tile_j];
				if !(tile_state.tile.flags & tile_flags.unplaceable) {
					var local_tile_i = tile_i - global.held_tile_offset[0]
					var local_tile_j = tile_j - global.held_tile_offset[1]
					global.held_tile_array[local_tile_i][local_tile_j] = tile_state
					if (global.selected_thing == thing_plucker)
						place_placeable(tile_i, tile_j, global.editor.current_empty_tile)
				}
				
			}
			else {
				var object_state = lvl.objects[tile_i][tile_j];
				var tile_state = lvl.tiles[tile_i][tile_j];
				
				var final_state;
				if !(object_state.tile.flags & tile_flags.unplaceable) {
					final_state = object_state
					if global.tile_mode == true
						global.editor.switch_tile_mode(false)		
				}
				else if !(tile_state.tile.flags & tile_flags.unplaceable){
					final_state = tile_state
					if global.tile_mode == false
						global.editor.switch_tile_mode(true)	
				}
				else 
					return;
				
				if (global.selected_thing == thing_plucker) {
					place_placeable(tile_i, tile_j, global.editor.current_empty_tile)
					audio_play_sound(pluck_sound, 10, false, 1.2)		
				}
				else
					audio_play_sound(pick_sound, 10, false, 1.2)
				
				global.selected_thing = thing_placeable
				switch_held_tile(new tile_with_state(final_state.tile, struct_copy(final_state.properties)))
				global.mouse_held = false;
				

			}
			return;
		case thing_eraser:
			place_placeable(tile_i, tile_j, global.editor.current_empty_tile)
			return;
		case thing_placeable:
			if (global.held_tile_state == global.editor.object_empty)
				return;
			place_placeable(tile_i, tile_j, global.held_tile_state.tile, struct_copy(global.held_tile_state.properties))
			return;
		case thing_multiplaceable:
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
						
					place_placeable(new_tile_i, new_tile_j, tile_state.tile, struct_copy(tile_state.properties), false)
				}
			}
			return;
		default:
			return;
			
	}
}

// This function runs last when handling a right click release (drag), or left click
function handle_click_after(tile_i, tile_j) {

	switch (global.selected_thing) {
		case thing_picker:
		case thing_plucker:
			if !dragging 
				return;
			var initial_empty_in_row = 14
			var empty_row = true
			for (var i = 0; i < array_length(global.held_tile_array); i++) {
				
				for (var j = 0; j < array_length(global.held_tile_array[i]); j++) {
					var tile_state = global.held_tile_array[i][j]
					var is_empty = (tile_state.tile == global.editor.current_empty_tile)
					if !is_empty {
						empty_row = false;
						initial_empty_in_row = min(initial_empty_in_row, j)
					}
				}
				
				if empty_row {
					array_delete(global.held_tile_array, i, 1)
					i--;	
				}
			}
				
			if (array_length(global.held_tile_array) == 0)
				return;
				
			if initial_empty_in_row != 0 {
				for (var i = 0; i < array_length(global.held_tile_array); i++) {
					array_delete(global.held_tile_array[i], 0, initial_empty_in_row)
				}	
			}
				
			var sound = (global.selected_thing == thing_plucker) ? pluck_sound : pick_sound;
			audio_play_sound(sound, 10, false, 1.2, 0, random_range(0.75, 0.85))
			
			
			global.selected_thing = thing_multiplaceable
			return;
		default:
			return;
	}
}

scale_x_start = image_xscale
scale_y_start = image_yscale

base_ui = agi("spr_ev_base_ui")

voidrod_sprite = agi("spr_voidrod_icon")
stackrod_sprite = agi("spr_voidrod_icon2")
burdens_sprite = agi("spr_items")
border_sprite = agi("spr_ev_display_border")

enum display_contexts {
	level_editor,
	level_select,
	level_select_pack,
	pack_editor,
}

draw_set_font(global.ev_font)

game_surface = noone
name_surface = noone
brand_surface = noone
cached_author_brand = lvl.author_brand;

highlighted = false

outside_view = false;

function destroy() {
	var gain = (room == global.pack_editor_room) ? global.pack_zoom_gain : 1
	audio_play_sound(agi("snd_stainedglass_break"), 10, false, gain, 0, random_range(0.9, 1));
	
	static shard_sprite = agi("spr_ev_display_shards");
	static shard_object = agi("obj_ev_display_shard");
	static shard_manager = agi("obj_ev_display_shard_manager");
	
	new_game_surface = surface_create(224, 144);
	surface_copy(new_game_surface, 0, 0, game_surface);
	
	var manager = instance_create_depth(x, y, 0, shard_manager, {
		game_surface : new_game_surface	,
		count : sprite_get_number(shard_sprite)
	});
	
	for (var i = 0; i < sprite_get_number(shard_sprite); i++) {
		instance_create_layer(x, y, layer,
			shard_object, { 
				game_surface : new_game_surface,
				manager : manager,
				image_index : i,
				image_xscale : image_xscale,
				image_yscale : image_yscale,
			});
	}
	instance_destroy(id)
}
function delete_cached_game_surface() {
	if surface_exists(game_surface)
		surface_free(game_surface)
}
function delete_cached_name_surface() {
	if surface_exists(name_surface)
		surface_free(name_surface)
}
