#macro MULTIPLIER_CHAR "X"


function level_struct() constructor {
	name = ""
	description = ""
	music = global.music_names[1];
	author = "Anonymous"
	author_brand = int64(0)
	burdens = [false, false, false, false, false]
	tiles = array_create(9);
	objects = array_create(9);
	theme = 0
	bount = -1; // brane count
	for (var i = 0; i < array_length(tiles) - 1; i++)
		tiles[i] = array_create(14, new tile_with_state(global.editor.tile_pit))	
	tiles[8] = array_create(14, new tile_with_state(global.editor.tile_unremovable))	
	
	for (var i = 0; i < array_length(objects); i++)
		objects[i] = array_create(14, new tile_with_state(global.editor.object_empty))	
		
	// This name will be used for when the file is saved.
	save_name = generate_save_name()
	upload_date = "";
	last_edit_date = "";
	
}
function place_default_tiles(level) {
	level.objects[@ 4][6] = new tile_with_state(global.editor.object_player)
	level.tiles[@ 2][6] = new tile_with_state(global.editor.tile_exit)
	for (var i = 0; i < 3; i++) {
		for (var j = 0; j < 3; j++)
			level.tiles[@ 3 + i][5 + j] = new tile_with_state(global.editor.tile_default)
	}	
	return level;
}

// just needs to be unique
function generate_save_name() {
	return base64_encode(date_string() + string(irandom($7fffffffffffffff)));	
}
function date_string() {
	var date = date_current_datetime();
	var year = date_get_year(date)
	var month = date_get_month(date)
	var day = date_get_day(date)
	var hour = date_get_hour(date)
	var minute = date_get_minute(date)
	var second = date_get_second(date)
	return string(second) + string(minute) + string(hour) + string(day) + string(month) + string(year);
}


function combine_strings(separator) {
	var str = ""
	for (var i = 1; i < argument_count - 1; i++)
		str += argument[i] + separator;
	return str + argument[argument_count - 1];
}

// TODO: as it is there is a lot of code copied twice for tiles and object tiles,
// reusing more code would be ideal.
function export_level_arr(level) {
	var version_string = string(global.latest_lvl_format);
	var name_string = base64_encode(level.name)	
	var description_string = base64_encode(level.description)	
	var music_string = base64_encode(level.music)	
	var author_string = base64_encode(level.author)
	var author_brand_string = string(level.author_brand)
	var burdens_string = string(level.burdens[0] + level.burdens[1] * 2 + level.burdens[2] * 4 + level.burdens[3] * 8 + level.burdens[4] * 16);
	var upload_date_string = "";
	var last_edit_date_string = "";

	var tile_string = ""
	var object_string = ""
	
	var tile_previous = "";
	var object_previous = ""
	
	var tile_multiplier = 1;
	var object_multiplier = 1;
	
	for (var i = 0; i < 9; i++)	{
		for (var j = 0; j < 14; j++) {
			if (i != 8) {
				var tile_state = level.tiles[i][j]
				var tile = tile_state.tile
				var addition = tile.iostruct.write(tile_state)
				
				if (addition == tile_previous)
					tile_multiplier++;
				else {
					if tile_multiplier != 1 { 
						tile_string += MULTIPLIER_CHAR + string(tile_multiplier)
						tile_multiplier = 1	
					}
					tile_string += addition;
				}
				tile_previous = addition
			}
			
			var addition = ""
			var object_state = level.objects[i][j]
			var object = object_state.tile
			
			addition += object.iostruct.write(object_state);
			
			if (addition == object_previous)
				object_multiplier++;
			else {
				if object_multiplier != 1 { 
					object_string += MULTIPLIER_CHAR + string(object_multiplier)
					object_multiplier = 1	
				}
				object_string += addition;
			}
			object_previous = addition
		}
	}
	
	if tile_multiplier != 1
		tile_string += MULTIPLIER_CHAR + string(tile_multiplier)
	
	if object_multiplier != 1 
		object_string += MULTIPLIER_CHAR + string(object_multiplier)
		
	var theme_string = string(level.theme);
	var bount_string = string(level.bount)
	return [version_string, name_string, description_string, music_string, 
		author_string, author_brand_string, upload_date_string, last_edit_date_string,
		burdens_string, tile_string, object_string, theme_string, bount_string]
}

// returns the level in string format
function export_level(level) {
	var arr = export_level_arr(level)
	var str = arr[0]
	for (var i = 1; i < array_length(arr); i++) {
		str += "|" + arr[i];
	}
	
	return str;
}

function level_string_content_sha1(level_string) {
	var arr = ev_string_split_buffer(level_string, "|", 100)
	if array_length(arr) < 11
		return sha1_string_utf8("fuck")
	var str = sha1_string_utf8(arr[8] + "|" + arr[9] + "|" + arr[10])
	return str;
}

function level_content_sha1(level) {
	var arr = export_level_arr(level)
	var str = sha1_string_utf8(arr[8] + "|" + arr[9] + "|" + arr[10])
	return str;
}


function get_level_version_from_string(level_string) {
	return int64_safe(read_string_until(level_string, 1, "|").substr, -1)
}

function get_level_name_from_string(level_string) {
	var start = string_pos("|", level_string) + 1;
	var ending = string_pos_ext("|", level_string, start);
		
	return base64_decode(string_copy(level_string, start, ending - start));
}

function get_level_date_from_string(level_string) {
	var count = 1;
	var start = string_pos_ext("|", level_string, 0) + 1;
	while (count != 6) {
		start = string_pos_ext("|", level_string, start) + 1;
		count++;
	}
	var str = string_copy(level_string, start, string_pos_ext("|", level_string, start) - start);
	return str;
}




enum level_themes {
	regular,
	universe,
	white_void
}

// imports a level from a level string
// TODO: this function is a bottleneck for all of EV. it is slow
// (more precisely, import_process_tiles is slow), and is called
// not only when loading levels, but also for packs (since they have a lot of levels!). 
// therefore, if you can optimize it that'd be great. the level format is a bit
// poorly engineered so it's a hard task.
function import_level(level_string) {
	var level = new level_struct()
	
	var strings = ev_string_split_buffer(level_string, "|", 100);
	var version_string = strings[0];
	var version = int64_safe(version_string, 0);
	if (version <= 0)
		return place_default_tiles(level)
	if (version > global.latest_lvl_format) {
		return place_default_tiles(level)
	}
	var section_amount;
	if version <= 2
		section_amount = 11;
	else
		section_amount = 13;
	
	if array_length(strings) != section_amount {
		return place_default_tiles(level);
	}
	
	level.name = base64_decode(strings[1]);
	level.description = base64_decode(strings[2]);
	level.music = base64_decode(strings[3]);
	level.author = base64_decode(strings[4])
	level.author_brand = int64(strings[5])
	level.upload_date = strings[6]
	level.last_edit_date = strings[7];
	
	var burdens = int64(strings[8]);

	for (var i = 0; i < 5; i++)
		level.burdens[i] = (burdens & (1 << i) != 0)

	var tile_string = strings[9]
	var object_string = strings[10]

	import_process_tiles(tile_string, level, 7, global.editor.tile_pit, version)
	import_process_tiles(object_string, level, 8, global.editor.object_empty, version)
	

	if (version <= 2) {
		level.theme = 0
		level.bount = -1;
	}
	else {
		level.theme = strings[11]
		level.bount = int64_safe(strings[12], -1)
	}
	return level
}
function import_process_tiles(tile_string, level, height, failsafe_tile, version) {
	var tile_pointer = 1
	var i = 0;
	var j = 0;
	while (tile_pointer < string_length(tile_string)) {
		var tile_id = string_copy(tile_string, tile_pointer, 2)
		tile_pointer += 2
		var tile = ds_map_find_value(global.placeable_name_map, tile_id)
		if is_undefined(tile)
			tile = failsafe_tile
			
		var result = tile.iostruct.read(tile, tile_string, tile_pointer, version)
			
		var state = result.value;
		var offset = result.offset;
		tile_pointer += offset;
			
		var result = get_multiplier(tile_string, tile_pointer);
		
		var mult = result.mult;
		tile_pointer += result.offset;
		
		repeat (mult) {
			if (tile.editor_type == editor_types.tile)
				level.tiles[@ i][j] = new tile_with_state(state.tile, struct_copy(state.properties))
			else
				level.objects[@ i][j] = new tile_with_state(state.tile, struct_copy(state.properties))
			
			j++;
			if (j >= 14) {
				j = 0;
				i++;
				if (i > height)
					return;
			}
		}	
	}
}

function get_multiplier(str, pointer) {
	if string_copy(str, pointer, 1) != MULTIPLIER_CHAR
		return { mult : 1, offset : 0};
	var num_string = "";
	var count = 1;
	while (true) {
		var read_char = string_copy(str, pointer + count, 1)
		if is_digit(read_char) {
			num_string += read_char
			count++;
			continue;
		}
		break;
	}
	var num = int64_safe(num_string, 1)
	return { mult : num, offset : count };
}


function level_get_exit_count(lvl) {
	static tile_exit = global.editor.tile_exit;
	static object_secret_exit = global.editor.object_secret_exit; 
	var exits = 0;
	for (var i = 0; i < 9; i++) {
		for (var j = 0; j < 14; j++) {
			if lvl.tiles[i][j].tile == tile_exit
				exits++;
			if lvl.objects[i][j].tile == object_secret_exit
				exits++;
		}
	}
	return exits;
}
function strip_level_for_pack(lvl) {
	lvl.description = ""
	lvl.music = ""
	lvl.author = ""
	lvl.burdens = [false, false, false, false, false]
	lvl.upload_date = ""
	lvl.last_edit_date = ""
	lvl.save_name = ""
	lvl.author_brand = 0;	
}

