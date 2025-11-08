// Object purpose: generic manager object for a lot of things EV does. 
// holds the tile/object structs, a lot of the global variables, 
// handles transitions, startup networking/file io and more

randomize()

global.is_html5 = (os_browser != browser_not_a_browser)

surface_depth_disable(false)
global.latest_lvl_format = 3;
global.latest_pack_format = 2;
global.ev_version = "0.995";
global.ev_fall_down_next_level = false;

if global.is_html5 {
	http_set_request_crossorigin("use-credentials");	
}
// debug flag that allows you to move buttons and textboxes with middle mouse
global.allow_moving_elements = false;


#macro agi asset_get_index 
global.is_merged = (agi("obj_game") != -1)
if (!global.is_merged) {
	var ratio = display_get_height() / 144
	surface_resize(application_surface, 224 * ratio, 144 * ratio)
	audio_group_load(audiogroup_void_stranger)
	global.debug = false;
	global.pause = false;
	global.music_inst = noone;
	global.music_file = noone;
	global.music_is_looping = false;
}

#macro level_extension "vsl"
#macro pack_extension "vspk"
#macro pack_password_extension "vspkp"
#macro pack_save_extension "vspks"
#macro pack_highscore_extension "vspkh"

global.save_directory = game_save_id
if global.is_html5
	global.save_directory = "";


global.server_ip = "skirlez.com"

global.author = { username : "Anonymous", brand : int64(irandom_range(0, $FFFFFFFFF)) }
global.stranger = 0;
global.logging_socket = noone

if !file_exists(global.save_directory + "ev_options.ini") {
	ev_load()
	ev_save();
}
else
	ev_load()
	
global.need_file_registry = global.is_html5
if global.need_file_registry
	global.file_registry = read_file_registry()

// Since there is no destructor for structs, we need to create a map
// to track structs that use maps so we can destroy them when they're garbage collected.
// This function is ran every set interval in alarm 0.

// This is completely unused and I don't remember what it was for.
global.struct_map_cleaner = ds_map_create()
function clean_struct_maps() {
	var keys = ds_map_keys_to_array_fix(global.struct_map_cleaner)
	for (var i = 0; i < array_length(keys); i++) {
		if weak_ref_alive(keys[i])
			continue;
		var map = ds_map_find_value(global.struct_map_cleaner, keys[i])
		ds_map_destroy(map);
	}
}
alarm[0] = 120;


// we can't really get unix time in milliseconds in gamemaker, so we just add current_time to this
date_set_timezone(timezone_utc)
try {
	var unix_seconds = int64(date_second_span(date_create_datetime(1970, 1, 1, 0, 0, 0), date_current_datetime()));
	global.unix_time = unix_seconds * int64(1000);
}
catch (e) {
	// very unnecessary futureproofing. i have no idea if this'll work, and no doubt nobody will be executing this when this
	// theoretically would be executed
	global.unix_time = int64(random_range(0, 70368744177664))	// 2^46
}
date_set_timezone(timezone_local)

window_set_cursor(cr_default)

// global.level is used for the level currently being edited / played.
// global.level_sha is only used for the level currently being played, in order to store its sha1 if beaten
global.level = noone;
global.level_sha = ""

// tracks locusts collected in this level
// is a map of positions (converted to integers by doing y * 14 + x)
// used as a hashset (only checking if entries exist)
global.locusts_collected_this_level = ds_map_create();

global.pack = noone;

global.editor_time = int64(0)
global.level_time = int64(0)

global.selected_thing_time = 0

global.mouse_pressed = false;
global.mouse_held = false;
global.mouse_released = false;

global.mouse_right_pressed = false;
global.mouse_right_held = false;
global.mouse_right_released = false;

global.g_mode = false;
global.void_radio_on = false;

#macro thing_nothing -1
#macro thing_plucker 0
#macro thing_eraser 1
#macro thing_placeable 2
#macro thing_multiplaceable 3
#macro thing_picker 6

enum tile_flags {
	// cannot be removed
	unremovable = 1,
	// if set, placing this tile will remove any previously placed tile of this type
	only_one = 2,
	// if set, cannot be picked up by picker or plucker
	unplaceable = 4
}

enum burden_types {
	memory,
	wings,
	sword,
	stackrod,
	swapper
}

global.editor_room = agi("rm_ev_editor");
global.pack_editor_room = agi("rm_ev_pack_editor");
global.level_room = agi("rm_ev_level");
global.pack_level_room = agi("rm_ev_pack_level");

global.editor = id;
global.display_object = agi("obj_ev_display");
global.node_object = agi("obj_ev_pack_node");

global.selection_sprite = agi("spr_ev_selection")
global.white_floor_sprite = agi("spr_floor_white")

global.tileset_1 = agi("tile_bg_1")
global.tileset_mon = agi("tile_bg_secret")
global.tileset_dis = agi("tile_bg_true")
global.tileset_ex = agi("tile_bg_void")
global.tileset_edge = agi("tile_edges")
global.tileset_edge_dis = agi("tile_edges_true")

global.select_sound = agi("snd_ev_select")

global.ev_font = agi("fnt_text_12")


return_tile_state_function = function(tile_state) { 
	return tile_state 
};

default_draw_function = function(tile_state, i, j/*, preview, lvl, no_spoilers*/) {
	draw_sprite(tile_state.tile.spr_ind, 0, j * 16 + 8, i * 16 + 8)	
}
music_draw_function = function(tile_state, i, j) {
	var spr = tile_state.tile.spr_ind
	draw_sprite(spr, ev_strobe_integer(sprite_get_number(spr)), j * 16 + 8, i * 16 + 8)	
}

default_reader = function(tile /*, lvl_str, pos, version*/ ) {
	var t = new tile_with_state(tile)
	return { value : t, offset : 0 }
}
default_writer = function(tile_state) {
	return tile_state.tile.tile_id
}
default_placer = function(tile_state, i, j /*, extra_data */) {
	var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name))
	if (inst.persistent)
		inst.persistent = false;
}

default_tile_io = { 
	read : default_reader,
	write : default_writer,
	place : default_placer
}

enum editor_types {
	tile,
	object
}
enum cube_types {
	uniform,
	uniform_constant,
	edge,
	edge_constant,
}

global.placeable_name_map = ds_map_create()

function editor_tile(display_name, spr_ind, tile_id, obj_name, obj_layer = "Floor", flags = 0) constructor {
	self.display_name = display_name
	self.spr_ind = spr_ind
	self.obj_name = obj_name
	self.obj_layer = obj_layer
	self.flags = flags
	self.draw_function = global.editor.default_draw_function
	self.place_function = global.editor.return_tile_state_function
	self.zed_function = noone
	self.tile_id = tile_id;
	self.properties_generator = return_noone;
	self.editor_type = editor_types.tile;
	self.iostruct = global.editor.default_tile_io;
	self.cube_type = cube_types.uniform;
	global.placeable_name_map[? tile_id] = self;
	
	function has_offset() {
		return false;	
	}
} 
function editor_object(display_name, spr_ind, tile_id, obj_name, obj_layer = "Instances", flags = 0) 
		: editor_tile(display_name, spr_ind, tile_id, obj_name, obj_layer, flags) constructor {
	self.editor_type = editor_types.object;
	
	function has_offset() {
		return has_offset_properties;	
	}
	// this flag must be set manually for the displays to render an object's offset
	has_offset_properties = false;
} 

#macro egg_statue_obj "obj_boulder"

function tile_state_has_edge(tile_state) {
	var tile = tile_state.tile
	if tile == tile_pit || tile == tile_glass
			|| tile == tile_edge || tile == tile_edge_dis
		return false;
		
	if tile == tile_mon_wall || tile == tile_ex_wall {
		if (tile_state.properties.ind == 9 || tile_state.properties.ind == 11 || tile_state.properties.ind == 10)
			return false;
	}
	return true;
}

#macro no_obj ""
#macro no_name ""

#region Tile Definitions

// used in cases a tile has a variable-length property/properties
#macro PROPERTY_END_CHAR "!"


function get_floor_sprite(lvl) {
	static floor_sprite = agi("spr_floor");
	static universe_floor_sprite = agi("spr_floor_alpha")
	static floorvanish_sprite = agi("spr_floor_unknown")
	if lvl.theme == level_themes.regular
		return floor_sprite
	if lvl.theme == level_themes.universe
		return universe_floor_sprite;
	return floorvanish_sprite;
}

function get_player_object_pos(lvl) {
	// player position is cached using static variables
	static player_i = 0;
	static player_j = 0;
	static player = global.editor.object_player;
	
	if lvl.objects[player_i][player_j].tile == player {
		return { i : player_i, j : player_j }
	}
	
	for (var i = 0; i < 9; i++) {
		for (var j = 0; j < 14; j++) {
			if (lvl.objects[i][j].tile == player) {
				player_i = i;
				player_j = j;
				return { i : i, j : j };
			}
		}
	}
	return { i : 4, j : 7 }
}

tile_default = new editor_tile("Floor", agi("spr_floor"), "fl", "obj_floor")
tile_default.cube_type = cube_types.edge_constant
tile_default.draw_function = function(tile_state, i, j, preview, lvl, no_spoilers) {
	var alpha = draw_get_alpha();
	if lvl.theme == level_themes.white_void {
		var pos = get_player_object_pos(lvl)
		var diff_i = abs(pos.i - i);
		var diff_j = abs(pos.j - j);
		delete pos;
		if (max(diff_i, diff_j) > 2) {
			alpha = alpha * 0.4 * !no_spoilers;
		}
	}
		
	draw_sprite_ext(get_floor_sprite(lvl), 0, j * 16 + 8, i * 16 + 8, 1, 1, 0, c_white, alpha)
}


// this is separated into a function since glass also calls it

// it may seem like this function is drawing the floor sprite,
// that's only because the edge graphic is the second index of that sprite

// this function is a big bottleneck for drawing levels, optimization would be good
function draw_pit(i, j, lvl, obscure_universe, no_spoilers) {
	static pit_sprite = agi("spr_pit");
	
	if i != 0 && global.editor.tile_state_has_edge(lvl.tiles[i - 1][j]) {
		static default_floor_sprite = agi("spr_floor");
		var spr;
		var alpha = draw_get_alpha();
		if lvl.tiles[i - 1][j].tile == global.editor.tile_default {
			if lvl.theme == level_themes.white_void {
				// maybe we need to not draw because the tile itself also isn't drawing
				var pos = get_player_object_pos(lvl)
				var diff_i = abs(pos.i - (i - 1));
				var diff_j = abs(pos.j - j);
				delete pos;
				if (max(diff_i, diff_j) > 2) {
					alpha = alpha * 0.4 * !no_spoilers;
				}
			}
			
			spr = get_floor_sprite(lvl); // default tile might have themed edge
		}
		else {
			spr = default_floor_sprite;
		}
		draw_sprite_ext(spr, 1, j * 16 + 8, i * 16 + 8, 1, 1, 0, c_white, alpha)
	}
	else if obscure_universe && lvl.theme == level_themes.universe {
		draw_sprite(pit_sprite, 1, j * 16 + 8, i * 16 + 8) // draw black square to hide away the universe background
	}	
}


tile_pit = new editor_tile(no_name, agi("spr_pit"), "pt", "obj_pit", "Pit", tile_flags.unplaceable)
tile_pit.draw_function = function(tile_state, i, j, preview, lvl, no_spoilers) {
	draw_pit(i, j, lvl, true, no_spoilers)
}
tile_pit.iostruct = {
	read: default_reader,
	write : default_writer,
	place : function(tile_state, i, j, extra_data) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		if instance_exists(inst.pit_bg)
				&& (i == 0 
				|| !global.editor.tile_state_has_edge(extra_data.lvl.tiles[i - 1][j]))
			inst.pit_bg.no_edge = true;
			
	}
}


tile_glass = new editor_tile("Glass", agi("spr_glassfloor"), "gl", "obj_glassfloor", "Floor_INS")
tile_glass.draw_function = function(tile_state, i, j, preview, lvl, no_spoilers) {
	draw_pit(i, j, lvl, false, no_spoilers)
	default_draw_function(tile_state, i, j)
}
tile_bomb = new editor_tile("Bomb Tile", agi("spr_bombfloor"), "mn", "obj_bombfloor")
tile_explo = new editor_tile("Lit Bomb Tile", agi("spr_explofloor"), "xp", "obj_explofloor")


tile_floorswitch = new editor_tile("Button", agi("spr_floorswitch"), "fs", "obj_floorswitch")
tile_floorswitch.draw_function = function(tile_state, i, j, preview, lvl) {
	var ind = lvl.objects[i][j].tile == object_empty ? 0 : 1
	draw_sprite(tile_state.tile.spr_ind, ind, j * 16 + 8, i * 16 + 8)
}
tile_floorswitch.cube_type = cube_types.edge

tile_copyfloor = new editor_tile("Shade Tile", agi("spr_copyfloor"), "cr", "obj_copyfloor")
tile_copyfloor.cube_type = cube_types.edge

tile_exit = new editor_tile("Exit", agi("spr_stairs"), "ex", "obj_exit")
tile_exit.iostruct = {
	read : default_reader,
	write : default_writer,
	place : function (tile_state, i, j, extra_data) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name))
		inst.ev_exit_number = extra_data.current_exit_number;
		extra_data.current_exit_number++;
	}
}

tile_exit.cube_type = cube_types.edge

function can_tile_press_buttons(tile) {
	static exceptions = [object_empty, object_hologram, object_secret_exit]
	for (var i = 0; i < array_length(exceptions); i++) {
		if (tile == exceptions[i])
			return false;
	}
	return true;
}

function level_has_unpressed_button(lvl) {
	// TODO calculate hash to cache this result? maybe?
	
	static fs = tile_floorswitch;
	for (var i = 0; i < 8; i++) {
		for (var j = 0; j < 14; j++) {
			if (lvl.tiles[i][j].tile == fs && !can_tile_press_buttons(lvl.objects[i][j].tile))
				return true;
		}
	}	
	return false;
}


tile_exit.draw_function = function(tile_state, i, j, preview, lvl) {
	draw_sprite(tile_state.tile.spr_ind, level_has_unpressed_button(lvl) ? 4 : 0, j * 16 + 8, i * 16 + 8)
}

tile_white = new editor_tile("Blank Tile", agi("spr_floor_white"), "wh", "obj_floor_blank")

tile_deathfloor = new editor_tile("Lightning Tile", agi("spr_deathfloor"), "df", "obj_deathfloor")
tile_deathfloor.cube_type = cube_types.edge


tilemap_tile_read = function(tile_id, lvl_str, pos) {
	var read_ind = string_copy(lvl_str, pos, 2)
	var ind = clamp(int64_safe(read_ind, 0), 0, 255)
	var t = new tile_with_state(tile_id, { ind : ind });
	return { value : t, offset : 2 };
}
tilemap_tile_write = function(tile_state) {
	return tile_state.tile.tile_id + num_to_string(tile_state.properties.ind, 2);
}

function make_sprite_from_tileset(tileset, ind) {
	var surf = surface_create(16, 16)
	surface_set_target(surf)
	draw_tile(tileset, ind, 0, 0, 0)
	var spr = sprite_create_from_surface(surf, 0, 0, 16, 16, false, false, 8, 8)
	surface_reset_target()
	surface_free(surf)	
	return spr;
}

enum edge_types {
	normal,
	dis,
	size
}

function make_edge_tile(name, tid, type) {
	var spr = make_sprite_from_tileset(get_edge_type_tileset(type), 31)
	var tile = new editor_tile(name, spr, tid, no_obj, "Floor")
	tile.draw_function = function(tile_state, i, j, preview, lvl) {
		draw_set_color(c_white)
		draw_tile(get_edge_type_tileset(tile_state.tile.edge_type), preview ? runtile_fetch_blob(j, i, lvl) : tile_state.properties.ind, 0, j * 16, i * 16)
	}
	tile.edge_type = type
	tile.properties_generator = function() {
		return { ind : 4 }	
	}
	tile.place_function = function(tile_state, i, j, lvl) {
		tile_state.properties.ind = runtile_fetch_blob(j, i, lvl);
		return tile_state;
	}
	tile.iostruct = {
		read : tilemap_tile_read,
		write : tilemap_tile_write,
		place : function(tile_state, i, j, extra_data) {
			tilemap_set(extra_data.edge_tilemaps[tile_state.tile.edge_type], tile_state.properties.ind, j, i)
			var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, "Pit", agi(global.editor.tile_pit.obj_name))
			instance_destroy(inst.pit_bg)
		}
	}
	tile.cube_type = cube_types.uniform_constant
	return tile;
}

tile_edge = make_edge_tile("Edge Tile", "ed", edge_types.normal)
tile_edge_dis = make_edge_tile("DIS Edge Tile", "de", edge_types.dis)

enum wall_types {
	normal,
	mon,
	dis,
	ex,
	size
}

function make_wall_tile(name, tid, type) {
	var spr = make_sprite_from_tileset(get_wall_type_tileset(type), 4)
	var tile = new editor_tile(name, spr, tid, no_obj, "Floor");
	tile.draw_function = function(tile_state, i, j) {
		draw_set_color(c_white)
		draw_tile(get_wall_type_tileset(tile_state.tile.wall_type), tile_state.properties.ind, 0, j * 16, i * 16)	
	}
	tile.zed_function = function(tile_state) {
		new_window(10, 4.5, agi("obj_ev_wall_window"), {
			type : tile_state.tile.wall_type,	
		})	
		global.mouse_layer = 1
	}
	tile.wall_type = type;
	
	tile.properties_generator = function() {
		return { ind : 4 }
	}

	tile.iostruct = {
		read : tilemap_tile_read,
		write : tilemap_tile_write,
		place : function(tile_state, i, j, extra_data) {
			tilemap_set(extra_data.wall_tilemaps[tile_state.tile.wall_type], tile_state.properties.ind, j, i)
			if global.editor.tile_state_has_edge(tile_state)
				instance_create_layer(j * 16 + 8, i * 16 + 8, "More_Pit", agi("obj_ev_pit_drawer"))
		}
	}

	tile.cube_type = cube_types.edge
	return tile;
}


tile_wall = make_wall_tile("Wall", "wa", wall_types.normal)
tile_mon_wall = make_wall_tile("Funhouse Wall", "mw", wall_types.mon)
tile_dis_wall = make_wall_tile("DIS Wall", "dw", wall_types.dis)
tile_ex_wall = make_wall_tile("EX Wall", "ew", wall_types.ex)


tile_black_floor = new editor_tile("Black Floor", agi("spr_ev_blackfloor"), "bl", "obj_floor")
tile_black_floor.iostruct = {
	read : default_reader,
	write : default_writer,
	place : function(tile_state, i, j) {
		instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name), {
			black_floor : true,	
		});
		
		// We create this object to prevent the player from grabbing the tile.
		instance_create_layer(j * 16 + 8, i * 16 + 8, "Instances", agi("obj_jewel_collect"), {
			visible : false	
		});
	}
}
tile_black_floor.cube_type = cube_types.edge



enum chest_items {
	locust,
	memory,
	wings,
	sword,
	empty,
	opened,
	swapper,
	endless,
	size // cool trick!
}

tile_chest = new editor_tile("Chest", agi("spr_chest_regular"), "st", "obj_chest_small", "Floor_INS")
tile_chest.properties_generator = function () {
	return { itm : chest_items.locust }	
}
tile_chest.zed_function = function(tile_state) {
	new_window(6, 5, agi("obj_ev_chest_window"), {
		chest_properties : tile_state.properties
	})
	global.mouse_layer = 1
}

tile_chest.draw_function = function (tile_state, i, j, preview, lvl) {
	static spr_burden_chest = agi("spr_chest_small");
	var itm = tile_state.properties.itm;
	
	var spr	= (itm == chest_items.locust || itm == chest_items.empty || itm == chest_items.opened)
			? tile_state.tile.spr_ind
			: spr_burden_chest;
	
	var ind = (itm == chest_items.opened)
		|| (itm == chest_items.memory && lvl.burdens[burden_types.memory])
		|| (itm == chest_items.wings && lvl.burdens[burden_types.wings])
		|| (itm == chest_items.sword && lvl.burdens[burden_types.sword])
		|| (itm == chest_items.endless && lvl.burdens[burden_types.stackrod])
		|| (itm == chest_items.swapper && lvl.burdens[burden_types.swapper]);

	draw_sprite(spr, ind, j * 16 + 8, i * 16 + 8)	
}

function chest_get_contents_num(item_id) {
	switch (item_id) {
		case chest_items.locust: return 1;
		case chest_items.memory: return 4;
		case chest_items.wings: return 3;
		case chest_items.sword: return 2;
		case chest_items.empty: return 0;
		case chest_items.opened: return 5;
		case chest_items.swapper: return 495;
		case chest_items.endless: return 7;
		default: return 1;
	}
}

tile_chest.iostruct = {
	read : function(tile, lvl_str, pos) {
		var read_item = string_copy(lvl_str, pos, 2)
		var item = clamp(int64_safe(read_item, 0), 0, chest_items.size - 1)
		var t = new tile_with_state(tile, { itm : item });
		return { value : t, offset : 2 };
	},
	write : function (tile_state) {
		return tile_state.tile.tile_id + num_to_string(tile_state.properties.itm, 2);	
	},
	place : function (tile_state, i, j, extra_data) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		inst.persistent = false;
		
		if room == global.pack_level_room 
				&& tile_state.properties.itm == chest_items.locust 
				&& ds_map_exists(global.locusts_collected_this_level, i * 14 + j) 
			inst.contents = global.editor.chest_get_contents_num(chest_items.empty)
		else
			inst.contents = global.editor.chest_get_contents_num(tile_state.properties.itm)
		
		// For the edge to appear if a glass tile is below the chest, 
		// we create a normal tile. This is consistent with the base game.
		instance_create_layer(j * 16 + 8, i * 16 + 8, "Floor", agi("obj_floor"))
	}
}

// code slightly modified from gml_Object_obj_floor_hpn_Draw_0, line ~162
function numbered_tile_draw_text(num, pos_x, pos_y) {
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_font(global.ev_font)
	var num_str;
	if (num < 10)
		num_str = "0" + string(num);
	else
		num_str = string(num);
	for (var i = 0; i < string_length(num_str); i++)
	{
		var char = string_char_at(num_str, i + 1);
		var x_offset = (char == "1") ? 1 : 0;
		draw_text_color(pos_x - 8 + (i * 8) + x_offset, pos_y - 8, char, c_black, c_black, c_black, c_black, 1);
	}
	

}

var numbered_tile_surface = surface_create(16, 16)
surface_set_target(numbered_tile_surface)
draw_sprite(agi("spr_floor_white"), 0, 8, 8)
numbered_tile_draw_text(99, 8, 8)
var numbered_tile_sprite = sprite_create_from_surface(numbered_tile_surface, 0, 0, 16, 16, false, false, 8, 8)
surface_reset_target()
surface_free(numbered_tile_surface)	

tile_number_floor = new editor_tile("Numbered Tile", numbered_tile_sprite, "nm", "obj_floor_hpn", "Floor")
tile_number_floor.properties_generator = function () {
	return { num : 99 }
}
tile_number_floor.iostruct = {
	read : function(tile_id, lvl_str, pos) {
	var read_num = string_copy(lvl_str, pos, 2)
	var num = clamp(int64_safe(read_num, 0), 0, 99)
	var t = new tile_with_state(tile_id, { num : num });
	return { value : t, offset : 2 };
	},
	write : function(tile_state) {
		return tile_state.tile.tile_id + num_to_string(tile_state.properties.num, 2);
	},
	place : function (tile_state, i, j) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		inst.dummy_value = tile_state.properties.num;
	}	
}

tile_number_floor.draw_function = function(tile_state, i, j, preview, lvl, no_spoilers) {
	static white_floor_sprite = agi("spr_floor_white");
	draw_sprite(white_floor_sprite, 0, j * 16 + 8, i * 16 + 8)	

	var num = tile_state.properties.num;
	numbered_tile_draw_text(num, j * 16 + 8, i * 16 + 8);
}
tile_number_floor.zed_function = function(tile_state) {
	new_window(6, 6, agi("obj_ev_number_tile_window"), { 
		tile_properties : tile_state.properties,
	})	
	global.mouse_layer = 1
}
tile_number_floor.cube_type = cube_types.edge

tile_unremovable = new editor_tile(no_name, agi("spr_floor_white"), "ur", no_obj, "Floor", tile_flags.unremovable|tile_flags.unplaceable)
tile_unremovable.draw_function = empty_function;

object_empty = new editor_object(no_name, noone, "em", no_obj, "Instances", tile_flags.unplaceable)
object_empty.draw_function = empty_function;
object_empty.iostruct = {
	read: default_reader,
	write : default_writer,
	place : function () { }
}

sweat_sprite = agi("spr_sweat")
object_player = new editor_object("Player", agi("spr_player_down"), "pl", "obj_spawnpoint", "Instances", tile_flags.unremovable|tile_flags.only_one)
object_player.draw_function = function(tile_state, i, j, preview, lvl) {
	var spr = ev_get_stranger_down_sprite(global.stranger)
	if (preview && lvl.tiles[i][j].tile == tile_pit) {
		draw_sprite(spr, ev_strobe_integer(2), j * 16 + 8 + dsin(global.editor_time * 24), i * 16 + 8)		
		draw_sprite(sweat_sprite, global.editor_time / 5, j * 16 + 16, i * 16)
		return;
	}
	draw_sprite(spr, ev_strobe_integer(2), j * 16 + 8, i * 16 + 8)	
}
object_player.iostruct = {
	read : default_reader,
	write : default_writer,
	place : function (tile_state, i, j) {
		var obj;
		if global.ev_fall_down_next_level {
			obj = agi("obj_enter_the_secret")
			global.ev_fall_down_next_level = false;	
		}
		else
			obj = agi(tile_state.tile.obj_name);
		
		instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, obj);
	},
}


object_leech = new editor_object("Leech", agi("spr_cl_right"), "cl", "obj_enemy_cl")
object_leech.draw_function = function(tile_state, i, j) {
	var xscale = tile_state.properties.dir == 1 ? -1 : 1
	draw_sprite_ext(tile_state.tile.spr_ind, ev_strobe_integer(2), j * 16 + 8, i * 16 + 8, xscale, 1, 0, c_white, draw_get_alpha())
}
maggot_sprite_down = agi("spr_cc_down");
maggot_sprite_up = agi("spr_cc_up");

object_maggot = new editor_object("Maggot", maggot_sprite_down, "cc", "obj_enemy_cc")
object_maggot.draw_function = function(tile_state, i, j) {
	draw_sprite(tile_state.properties.dir == 1 ? maggot_sprite_up : maggot_sprite_down, ev_strobe_integer(2), j * 16 + 8, i * 16 + 8)
}
var directioned_zed_function = function(tile_state) {
	tile_state.properties.dir = !tile_state.properties.dir
}
var directioned_properties = function() {
	return { dir : false }
}
var directioned_iostruct = {
	read : function(tile_id, lvl_str, pos) {
		var read_dir = string_copy(lvl_str, pos, 1)
		var dir = bool(int64_safe(read_dir, 0))
		var t = new tile_with_state(tile_id, { dir : dir })
		return { value : t, offset : 1 };
	},
	write : function(tile_state) {
		return tile_state.tile.tile_id + (tile_state.properties.dir == true ? "1" : "0");
	},
	place : function (tile_state, i, j) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		inst.editor_dir = tile_state.properties.dir;
	}
}

object_leech.zed_function = directioned_zed_function
object_leech.properties_generator = directioned_properties
object_leech.iostruct = directioned_iostruct

object_maggot.zed_function = directioned_zed_function
object_maggot.properties_generator = directioned_properties
object_maggot.iostruct = directioned_iostruct

object_bull = new editor_object("Beaver", agi("spr_cg_idle"), "cg", "obj_enemy_cg")
object_bull.draw_function = music_draw_function
object_gobbler = new editor_object("Smile", agi("spr_cs_right"), "cs", "obj_enemy_cs")
object_gobbler.draw_function = music_draw_function
object_hand = new editor_object("Eye", agi("spr_ch"), "ch", "obj_enemy_ch")
object_hand.draw_function = music_draw_function
object_mimic = new editor_object("Mimic", agi("spr_cm_down"), "cm", "obj_enemy_cm")
object_mimic.properties_generator = function() {
	return { typ : 0 } 	
}
object_mimic.zed_function = function(tile_state) {
	tile_state.properties.typ++;
	if tile_state.properties.typ > 2
		tile_state.properties.typ = 0
}
mimic_sprite_arr = [agi("spr_cm_down"), agi("spr_cm_up1"), agi("spr_cm_up2")]
object_mimic.draw_function = function(tile_state, i, j) {
	draw_sprite(mimic_sprite_arr[tile_state.properties.typ], ev_strobe_integer(2), j * 16 + 8, i * 16 + 8)
}
object_mimic.iostruct = {
	read : function(tile_id, lvl_str, pos) {
		var read_type = string_copy(lvl_str, pos, 1)
		var type = clamp(int64_safe(read_type, 0), 0, 2)
		var t = new tile_with_state(tile_id, { typ: type })
		return { value : t, offset : 1 };
	},
	write : function(tile_state) {
		return tile_state.tile.tile_id + string(tile_state.properties.typ);
	},
	place : function (tile_state, i, j) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		inst.editor_type = tile_state.properties.typ;
	}	
}

object_diamond = new editor_object("Octahedron", agi("spr_co_idle"), "co", "obj_enemy_co")
object_diamond.draw_function = function(tile_state, i, j) {
	draw_sprite(tile_state.tile.spr_ind, ev_strobe_fasttriplet_real(2), j * 16 + 8, i * 16 + 8)	
}

object_spider = new editor_object("Spider", agi("spr_ct_right"), "ct", "obj_enemy_ct")
object_spider.draw_function = function(tile_state, i, j) {
	var ind = (tile_state.properties.ang == 2 || tile_state.properties.ang == 3) 
		? 1 - ev_strobe_integer(2) : ev_strobe_integer(2)
		
	draw_sprite_ext(tile_state.tile.spr_ind, ind, j * 16 + 8, i * 16 + 8, 1, 1,
		tile_state.properties.ang * 90, c_white, draw_get_alpha())
}
object_spider.properties_generator = function() {
	return { ang : 0 }	
}
object_spider.zed_function = function(tile_state) {
	tile_state.properties.ang -= 1
	if tile_state.properties.ang < 0
		tile_state.properties.ang = 3
}
object_spider.iostruct = {
	read : function(tile_id, lvl_str, pos) {
		var read_angle = string_copy(lvl_str, pos, 1)
		var angle = clamp(int64_safe(read_angle, 0), 0, 3)
		var t = new tile_with_state(tile_id, { ang: angle })
		return { value : t, offset : 1 };
	},
	write : function(tile_state) {
		return tile_state.tile.tile_id + string(tile_state.properties.ang );
	},
	place : function (tile_state, i, j) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		var val = tile_state.properties.ang - 1
		if (val < 0)
			val = 3
		inst.set_e_direction = 3 - val;
	}		
}

object_orb = new editor_object("Orb Thing", agi("spr_cv"), "cv", "obj_enemy_cv")
object_orb.draw_function = function(tile_state, i, j) {
	draw_sprite(tile_state.tile.spr_ind, ev_strobe_integer(2), j * 16 + 8, i * 16 + 8)	
}

object_egg = new editor_object("Egg", agi("spr_boulder"), "eg", egg_statue_obj)
object_egg.properties_generator = function() {
	return { txt : array_create(4, "") }	
}
object_egg.zed_function = function(tile_state) {
	new_window(10, 6, agi("obj_ev_egg_window"), 
	{ egg_properties : tile_state.properties })	
	global.mouse_layer = 1
}

object_egg.draw_function = function(tile_state, i, j, preview, lvl, no_spoilers) {
	default_draw_function(tile_state, i, j)
	if no_spoilers
		return;
	static spr_eggtext = agi("spr_ev_eggtext");
	if (tile_state.properties.txt[0] != "") {
		draw_sprite(spr_eggtext, 0, j * 16 + 8, i * 16 + 8)
	}
}
object_egg.iostruct = {
	read : function(tile, lvl_str, pos) {
		var read_length = string_char_at(lvl_str, pos)
		var arrlen = clamp(int64_safe(read_length, 0), 0, 4);
		pos += 1;
		
		var txt_arr = array_create(4, "")
		var total_count = 0;
		
		for (var m = 0; m < arrlen; m++) {
			var endp = string_pos_ext(PROPERTY_END_CHAR, lvl_str, pos)	
			if (endp == 0)
				break;
			total_count += endp - pos + 1;
			var read_string = string_copy(lvl_str, pos, endp - pos)
			pos = endp + 1;
			txt_arr[m] = base64_decode(read_string)
		}
		var t = new tile_with_state(tile, { txt: txt_arr });
		return { value : t, offset : 1 + total_count };
	},
	write : function(tile_state) {
		var arrlen = array_length(tile_state.properties.txt)
		var encoded_text = "";
		var m;
		for (m = 0; m < arrlen; m++) {
			var txt = tile_state.properties.txt[m]
			if txt == ""
				break;
			encoded_text += base64_encode(txt) + PROPERTY_END_CHAR	
		}
		// TODO FORMAT VERSION 4: add a `PROPERTY_END_CHAR` here after string(m)
		return tile_state.tile.tile_id + string(m) + encoded_text
	},
	place : function (tile_state, i, j) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		with (inst) {
			var m;
			for (m = 0; m < 4; m++) {
				if tile_state.properties.txt[m] == ""
					break;
				text[m] = tile_state.properties.txt[m];
			}
			if m == 0
				break;
			special_message = -1
			voice = b_voice	
			moods = array_create(m, neutral)
			speakers = array_create(m, id)
		}
	}		
}


cif_sprite = agi("spr_atoner")
lamp_sprite = agi("spr_lamp")
object_cif = new editor_object("Cif Statue", cif_sprite, "cf", egg_statue_obj)
object_cif.properties_generator = function() {
	return { lmp : false }
}
object_cif.zed_function = function(tile_state) {
	tile_state.properties.lmp = !tile_state.properties.lmp
}
object_cif.draw_function = function(tile_state, i, j) {
	draw_sprite(tile_state.properties.lmp ? lamp_sprite : cif_sprite, 0, j * 16 + 8, i * 16 + 8)
}
object_cif.iostruct = {
	read : function(tile_id, lvl_str, pos) {
		var read_lamp = string_copy(lvl_str, pos, 1)
		var lamp = bool(int64_safe(read_lamp, 0))
		var t = new tile_with_state(tile_id, { lmp: lamp })
		return { value : t, offset : 1 };
	},
	write : function(tile_state) {
		return tile_state.tile.tile_id + string(tile_state.properties.lmp);
	},
	place : function (tile_state, i, j) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		if (tile_state.properties.lmp)
			inst.editor_lamp = true

		inst.b_form = 4
	}		
}


global.branefuck_characterset = ".,+-[]><?^_#:; ";
global.branefuck_persistent_memory = array_create(BRANEFUCK_MEMORY_AMOUNT)
function reset_branefuck_persistent_memory() {
	for (var i = 0; i < BRANEFUCK_MEMORY_AMOUNT; i++)
		global.branefuck_persistent_memory[i] = int64(0);
}
reset_branefuck_persistent_memory()

object_add = new editor_object("Add Statue", agi("spr_voider"), "ad", egg_statue_obj)
object_add.draw_function = function(tile_state, i, j, preview, lvl, no_spoilers) {
	draw_sprite(tile_state.tile.spr_ind, 0, j * 16 + 8, i * 16 + 8)
	if tile_state.properties.mde != 0 && !no_spoilers {
		
		static branefucked = agi("spr_ev_branefucked")
		draw_sprite(branefucked, 0, j * 16 + 8, i * 16 + 8)
	}
}
object_add.properties_generator = function() {
	return {
		mde : 0,
		val : "",
		pgm : "",
	}
}


object_add.iostruct = {
	read : function(tile, lvl_str, pos, version) {
		if (version == 1)
			return global.editor.default_reader(tile, lvl_str, pos)	
		var original_pos = pos;
		if (version == 2) {
			var read_mode = string_copy(lvl_str, pos, 1)
			var mode = int64_safe(read_mode, 0)	
			pos++;
			if (mode == 0) {
				var t = new tile_with_state(tile)
				return { value : t, offset : pos - original_pos }
			}
			var read_input_1 = read_string_until(lvl_str, pos, PROPERTY_END_CHAR)
			pos += read_input_1.offset + 1;
			if (mode == 1) {
				var read_destroy_value = read_string_until(lvl_str, pos, PROPERTY_END_CHAR)
				pos += read_destroy_value.offset + 1;
				var t = new tile_with_state(tile, {
					mde : 1,
					val : base64_decode(read_destroy_value.substr),
					pgm : base64_decode(read_input_1.substr),
				})
				return { value : t, offset : pos - original_pos }
			}
		
			var read_input_2 = read_string_until(lvl_str, pos, PROPERTY_END_CHAR)
			pos += read_input_2.offset + 1;
			var read_destroy_value = read_string_until(lvl_str, pos, PROPERTY_END_CHAR)
			pos += read_destroy_value.offset + 1;
			var read_program = read_string_until(lvl_str, pos, PROPERTY_END_CHAR)
			pos += read_program.offset + 1;
		
			// version 3 does not do inputs, convert inputs to branefuck instructions
			function input_to_code(input) {
				if (input == "")
					return "";
				if string_is_int(input) {
					var input_value = int64_safe(input, 0)
					if input_value == 0
						return "";
					if input_value > 0
						return "+" + input
					else
						return "-" + input
				}
				else
					return ",g:" + input + "," 
			}
		
			var prefix = input_to_code(base64_decode(read_input_1.substr)) + ">" 
				+ input_to_code(base64_decode(read_input_2.substr)) + "<"
			
			if prefix == "><"
				prefix = "";
		
			var t = new tile_with_state(tile, {
				mde : 2,
				val : base64_decode(read_destroy_value.substr),
				pgm : prefix + read_program.substr,
			})
			return { value : t, offset : pos - original_pos }
		}
		if (version == 3) {
			var read_mode = string_copy(lvl_str, pos, 1)
			var mode = int64_safe(read_mode, 0)	
			pos++;
			if (mode == 0) {
				var t = new tile_with_state(tile)
				return { value : t, offset : pos - original_pos }
			}
			pos++; // skip over PROPERTY_END_CHAR
			var read_program = read_string_until(lvl_str, pos, PROPERTY_END_CHAR)
			pos += read_program.offset + 1;
			var read_destroy_value = read_string_until(lvl_str, pos, PROPERTY_END_CHAR)
			pos += read_destroy_value.offset + 1;
			var t = new tile_with_state(tile, {
				mde : mode,
				val : base64_decode(read_destroy_value.substr),
				pgm : base64_decode(read_program.substr),
			})
			return { value : t, offset : pos - original_pos }
		}

	},
	write : function(tile_state) {
		var mode = tile_state.properties.mde
		var program = tile_state.properties.pgm;
		var destroy_value = tile_state.properties.val;
		
		if mode == 0 {
			return tile_state.tile.tile_id + "0"
		}
		return tile_state.tile.tile_id + string(mode) + PROPERTY_END_CHAR 
			+ base64_encode(program) + PROPERTY_END_CHAR 
			+ base64_encode(destroy_value) + PROPERTY_END_CHAR;
	},
	place : function (tile_state, i, j) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		inst.b_form = 8;
		
		var mode = tile_state.properties.mde;
		if mode == 0
			return;

		var program 
		if mode == 1 {
			program = $",g:{ tile_state.properties.pgm},";
		}
		else
			program = tile_state.properties.pgm
		instance_create_layer(0, 0, tile_state.tile.obj_layer, agi("obj_ev_branefucker"), {
			add_inst : inst,
			destroy_value_str : tile_state.properties.val,
			program_str : program,
		});
	},
};
object_add.zed_function = function(tile_state) {
	new_window(13, 8, agi("obj_ev_add_statue_window"), {
		add_properties : tile_state.properties
	})
	global.mouse_layer = 1
}

function voidlord_io(b_form) {
	return {
		read : default_reader,
		write : default_writer,
		place : function (tile_state, i, j) {
			var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
			inst.b_form = self.num
		},
		num : b_form
	};
}	

object_mon = new editor_object("Mon Statue", agi("spr_greeder"), "mo", egg_statue_obj)
object_mon.iostruct = voidlord_io(7)
object_tan = new editor_object("Tan Statue", agi("spr_killer"), "tn", egg_statue_obj)
object_tan.iostruct = voidlord_io(3)
object_lev = new editor_object("Lev Statue", agi("spr_watcher"), "lv", egg_statue_obj)
object_lev.iostruct = voidlord_io(1)
object_eus = new editor_object("Eus Statue", agi("spr_lover"), "eu", egg_statue_obj)
object_eus.iostruct = voidlord_io(6)
object_bee = new editor_object("Bee Statue", agi("spr_smiler"), "be", egg_statue_obj)
object_bee.iostruct = voidlord_io(2)
object_gor = new editor_object("Gor Statue", agi("spr_slower"), "go", egg_statue_obj)
object_gor.iostruct = voidlord_io(5)

object_jukebox = new editor_object("Jukebox", agi("spr_jb"), "jb", egg_statue_obj)
object_jukebox.iostruct = voidlord_io(9)

object_tis = new editor_object("Tis Statue", agi("spr_ev_tis_statue"), "ts", egg_statue_obj, "Tis")
object_tis.iostruct = voidlord_io(10)

var surface_tree = surface_create(16, 16)
surface_set_target(surface_tree)
draw_sprite(agi("spr_birch"), 0, 8, 8 - 24)
surface_reset_target()
var tree_sprite = sprite_create_from_surface(surface_tree, 0, 0, 16, 16, false, false, 8, 8);
surface_free(surface_tree)

object_tree = new editor_object("Tree", tree_sprite, "tr", "obj_rest");
object_tree.draw_function = function(tile_state, i, j) {
	// offset by 24 upwards so the stump is where the tile is placed
	static full_sprite = agi("spr_birch");
	draw_sprite(full_sprite, 0, j * 16 + 8, i * 16 + 8 - 24)	
}
object_tree.iostruct = {
	read : default_reader,
	write : default_writer,
	place : function (tile_state, i, j) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8 - 24, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		inst.persistent = false;
	},
}


object_secret_exit = new editor_object("Secret Exit", agi("spr_ev_secret_exit_arrow"), "se", "obj_na_secret_exit")

enum secret_exit_types {
	hidden,
	stars,
	stink,
}

object_secret_exit.properties_generator = function () {
	return { typ : secret_exit_types.hidden, ofx : 0, ofy : 0 }
}
object_secret_exit.has_offset_properties = true;

object_secret_exit.iostruct = {
	read : function(tile_id, lvl_str, pos, version) {
		if (version == 1) {
			var t = new tile_with_state(tile_id, { typ : 0, ofx : 0, ofy : 0 })
			return { value : t, offset : 0 };	
		}
		if version == 2 {
			var read_type = string_copy(lvl_str, pos, 1)
			var type = clamp(int64_safe(read_type, 0), 0, 2)
			var t = new tile_with_state(tile_id, { typ : type, ofx : 0, ofy : 0 })
			return { value : t, offset : 1 };	
		}
		// version 3
		var start_pos = pos;
		var read_type = string_copy(lvl_str, pos, 1)
		var type = clamp(int64_safe(read_type, 0), 0, 2);
		pos += 2; // skip type, property sep
		var read_offset_x = read_int(lvl_str, pos)
		var ofx = read_offset_x.number;
		pos += read_offset_x.offset + 1;
		
		var read_offset_y = read_int(lvl_str, pos)
		var ofy = read_offset_y.number;
		pos += read_offset_y.offset + 1;
		
		var t = new tile_with_state(tile_id, { typ : type, ofx : ofx, ofy : ofy })
		return { value : t, offset : pos - start_pos };
	},
	write : function(tile_state) {
		return tile_state.tile.tile_id 
			+ string(tile_state.properties.typ) + PROPERTY_END_CHAR
			+ string(tile_state.properties.ofx) + PROPERTY_END_CHAR
			+ string(tile_state.properties.ofy) + PROPERTY_END_CHAR;
	},
	place : function (tile_state, i, j, extra_data) {
		i += tile_state.properties.ofy;
		j += tile_state.properties.ofx;
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		
		var type = tile_state.properties.typ;
		
		if type == 1
			inst.secret_stars = true;
		else if type == 2
			instance_create_layer(j * 16 + 8, i * 16 + 8, "Effects", agi("obj_stinklines"))	
		inst.ev_exit_number = extra_data.current_exit_number;
		extra_data.current_exit_number++;
		
	}
}
/* scrapped in favor of offset projections
function draw_offset_arrow(i, j, ofx, ofy) {
	if (ofx == 0 && ofy == 0)
		return;
	var angle = darctan2(-ofy, ofx);
	angle = round(angle / 45) * 45
	draw_sprite_ext(agi("spr_ev_tile_offset_arrow"), 0, j * 16 + 8, i * 16 + 8, 1, 1, angle, c_white, 1)
}
*/
object_secret_exit.draw_function = function(tile_state, i, j, preview, lvl, no_spoilers) {
	if (no_spoilers)
		return;
	
	static stinklines_sprite = agi("spr_stinklines")
	static stars_sprite = agi("spr_soulstar_spark")
	draw_sprite(object_secret_exit.spr_ind, 0, j * 16 + 8, i * 16 + 8)
	var type = tile_state.properties.typ;
	if type == 1 {
		draw_sprite(object_secret_exit.spr_ind, 0, j * 16 + 8, i * 16 + 8)	
		draw_sprite(stars_sprite, 2, j * 16 + 5, i * 16 + 10)	
		draw_sprite(stars_sprite, 3, j * 16 + 13, i * 16 + 5)	
	}
	else if type == 2
		draw_sprite(stinklines_sprite, global.editor_time / 10, j * 16 + 8, i * 16 + 8)	
	//draw_offset_arrow(i, j, tile_state.properties.ofx, tile_state.properties.ofy)
}

object_secret_exit.zed_function = function(tile_state) {
	new_window(10, 8, agi("obj_ev_secret_exit_window"), {
		secret_exit_properties : tile_state.properties
	})	
	global.mouse_layer = 1
}

object_hungry_man = new editor_object("Famished Man", agi("spr_fam_u"), "hu", "obj_npc_famished")
object_hungry_man.draw_function = music_draw_function


// we make a memory crystal sprite with an outline for the object selection window only, in the draw
// function it uses the unmodified sprite
crystal_sprite = agi("spr_token_floor");

var surface_crystal = surface_create(16, 16)
surface_set_target(surface_crystal)

draw_sprite_ext(crystal_sprite, 0, 8 - 1, 8, 1, 1, 0, c_black, 1)
draw_sprite_ext(crystal_sprite, 0, 8 + 1, 8, 1, 1, 0, c_black, 1)
draw_sprite_ext(crystal_sprite, 0, 8, 8 - 1, 1, 1, 0, c_black, 1)
draw_sprite_ext(crystal_sprite, 0, 8, 8 + 1, 1, 1, 0, c_black, 1)

draw_sprite(crystal_sprite, 0, 8, 8)

surface_reset_target()


var crystal_sprite_with_outline = sprite_create_from_surface(surface_crystal, 0, 0, 16, 16, false, false, 8, 8)
surface_free(surface_crystal)

object_memory_crystal = new editor_object("Memory Crystal", crystal_sprite_with_outline, "mm", "obj_token_uncover", "Instances", tile_flags.only_one)
object_memory_crystal.properties_generator = function () {
	return { ofx : 0, ofy : 0 }
}
object_memory_crystal.has_offset_properties = true;
object_memory_crystal.iostruct = {
	read : function(tile_id, lvl_str, pos, version) {
		if version <= 2 {
			var t = new tile_with_state(tile_id, { ofx : 0, ofy : 0 })
			return { value : t, offset : 0 };	
		}
		var start_pos = pos;
		var read_offset_x = read_int(lvl_str, pos)
		var ofx = read_offset_x.number;
		pos += read_offset_x.offset + 1;
		
		var read_offset_y = read_int(lvl_str, pos)
		var ofy = read_offset_y.number;
		pos += read_offset_y.offset + 1;
		
		var t = new tile_with_state(tile_id, { ofx : ofx, ofy : ofy })
		return { value : t, offset : pos - start_pos };
	},
	write : function(tile_state) {
		return tile_state.tile.tile_id 
			+ string(tile_state.properties.ofx) + PROPERTY_END_CHAR
			+ string(tile_state.properties.ofy) + PROPERTY_END_CHAR;
	},
	place : function (tile_state, i, j, extra_data) {
		if !extra_data.should_create_memory
			return;
		i += tile_state.properties.ofy;
		j += tile_state.properties.ofx;
		instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
	}
}
object_memory_crystal.draw_function = function(tile_state, i, j, preview, lvl, no_spoilers) {
	draw_sprite(global.editor.crystal_sprite, 0, j * 16 + 8, i * 16 + 8)	
}
object_memory_crystal.zed_function = function(tile_state) {
	new_window(7, 7, agi("obj_ev_memory_crystal_window"), {
		memory_crystal_properties : tile_state.properties
	})	
	global.mouse_layer = 1
}


// The lengths I go to to not include base game sprites in the source.
#region Create Scaredeer Sprite
var surface_deer = surface_create(16, 16)
surface_set_target(surface_deer)


draw_sprite(agi("spr_ee_enemy_reaper"), 0, 0, -16 * 3)
scaredeer_sprite_r = sprite_create_from_surface(surface_deer, 0, 0, 16, 16, false, false, 8, 8)

draw_clear_alpha(c_black, 0)
draw_sprite(agi("spr_ee_enemy_reaper"), 1, 0, -16 * 3)
var scaredeer_sprite_r_2 = sprite_create_from_surface(surface_deer, 0, 0, 16, 16, false, false, 8, 8)

draw_clear_alpha(c_black, 0)
draw_sprite_ext(agi("spr_ee_enemy_reaper"), 0, 16, -16 * 3, -1, 1, 0, c_white, 1)
scaredeer_sprite_l = sprite_create_from_surface(surface_deer, 0, 0, 16, 16, false, false, 8, 8)

draw_clear_alpha(c_black, 0)
draw_sprite_ext(agi("spr_ee_enemy_reaper"), 1, 16, -16 * 3, -1, 1, 0, c_white, 1)
var scaredeer_sprite_l_2 = sprite_create_from_surface(surface_deer, 0, 0, 16, 16, false, false, 8, 8)

scaredeer_sprite_fall = sprite_duplicate(scaredeer_sprite_r);
sprite_merge(scaredeer_sprite_fall, scaredeer_sprite_l_2)
sprite_merge(scaredeer_sprite_fall, scaredeer_sprite_l)
sprite_merge(scaredeer_sprite_fall, scaredeer_sprite_r_2)

sprite_merge(scaredeer_sprite_r, scaredeer_sprite_r_2)
sprite_merge(scaredeer_sprite_l, scaredeer_sprite_l_2)

sprite_delete(scaredeer_sprite_l_2)
sprite_delete(scaredeer_sprite_r_2)

surface_reset_target()
surface_free(surface_deer)
#endregion

object_scaredeer = new editor_object("Scaredeer", scaredeer_sprite_r, "sd", "obj_enemy_cs")
object_scaredeer.draw_function = music_draw_function;
object_scaredeer.iostruct = { 
	read : default_reader,
	write : default_writer,
	place : function (tile_state, i, j) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		with (inst) {
			ev_scaredeer = true;
			spr_l = global.editor.scaredeer_sprite_l
			spr_r = global.editor.scaredeer_sprite_r
			e_fall_sprite = global.editor.scaredeer_sprite_fall
			e_falling_sprite = agi("spr_fall");
		}
	},
}


var hologram_surf = surface_create(16, 16)
surface_set_target(hologram_surf)
draw_sprite(agi("spr_boulder"), 0, 8, 8)
draw_sprite(agi("spr_question_black"), 8, 8, 8)
var hologram_sprite = sprite_create_from_surface(hologram_surf, 0, 0, 16, 16, false, false, 8, 8)
surface_reset_target()
surface_free(hologram_surf)

object_hologram = new editor_object("Fake Egg", hologram_sprite, "ho", "obj_fakewall")

object_hologram.draw_function = function(tile_state, i, j, preview, lvl, no_spoilers) {
	if no_spoilers {
		draw_sprite(global.editor.object_egg.spr_ind, 0, j * 16 + 8, i * 16 + 8)
		return;
	}
	default_draw_function(tile_state, i, j)
}

function mural_get_image_index(i, j, lvl) {
	static mural_object = global.editor.object_mural
	static wall_tile = global.editor.tile_wall
	
	var img;
	if j > 0 && lvl.objects[i][j - 1].tile == mural_object
		img = 1;
	else
		img = 0;
	if lvl.tiles[i][j].tile == wall_tile
		img += 2;
	return img;
}
object_mural = new editor_object("Mural", agi("spr_ev_mural"), "mu", "obj_mural")
object_mural.iostruct = {
	read : function(tile_id, lvl_str, pos) {
		var start_pos = pos;
		var read_brand = read_string_until(lvl_str, pos, "!")
		var brand = int64_safe(read_brand.substr, 1)
		pos += read_brand.offset + 1;
		var read_text = read_string_until(lvl_str, pos, "!")
		var text = base64_decode(read_text.substr)
		pos += read_text.offset + 1;
		var t = new tile_with_state(tile_id, { brd : brand, txt : text })
		return { value : t, offset : pos - start_pos };
	},
	write : function(tile_state) {
		return $"{tile_state.tile.tile_id}{tile_state.properties.brd}{PROPERTY_END_CHAR}{base64_encode(tile_state.properties.txt)}{PROPERTY_END_CHAR}"
	},
	place : function(tile_state, i, j, extra_data) {
		var inst = instance_create_layer(j * 16 + 8, i * 16 + 8, tile_state.tile.obj_layer, agi(tile_state.tile.obj_name));
		inst.sprite_index = agi("spr_ev_mural")
		inst.image_speed = global.editor.mural_get_image_index(i, j, extra_data.lvl);
		inst.inscription = 19;
		inst.ev_mural_brand = tile_state.properties.brd;
		inst.ev_mural_text = tile_state.properties.txt;
	}
}
object_mural.draw_function = function(tile_state, i, j, preview, lvl) {
	var img = global.editor.mural_get_image_index(i, j, lvl)

	draw_sprite(tile_state.tile.spr_ind, img, j * 16 + 8, i * 16 + 8)
}
object_mural.properties_generator = function () {
	return {
		brd : int64(0),
		txt : "",
	}
}
object_mural.zed_function = function(tile_state) {
	new_window(10, 8, agi("obj_ev_mural_window"), {
		mural_properties : tile_state.properties
	})	
	global.mouse_layer = 1
}


global.player_tiles = array_create(7)
global.player_objects = array_create(7)
for (var i = 0; i < 7; i++) {
	global.player_tiles[i] = i	
	global.player_objects[i] = i	
}

// These are the lists of tiles and objects that are read by obj_ev_placeable_selection. If you
// want your tile/object to be placable in the editor, it should be included here.

tiles_list = [tile_default, tile_glass, tile_bomb, tile_explo, tile_floorswitch, tile_copyfloor, tile_exit, 
	tile_deathfloor, tile_black_floor, tile_number_floor, tile_white, tile_wall, tile_mon_wall, tile_dis_wall, tile_ex_wall, tile_edge, tile_edge_dis, tile_chest]

objects_list = [object_player, object_leech, object_maggot, object_bull, object_gobbler, object_hand, 
	object_mimic, object_diamond, object_hungry_man, object_add, object_cif, object_bee, object_tan, object_lev, object_mon, object_eus, object_gor, 
	object_jukebox, object_egg, object_hologram, object_tree, object_memory_crystal, object_secret_exit, object_mural,
	object_spider, object_scaredeer, object_orb, object_tis]

#endregion


// Tile holding in editor
global.held_tile_state = new tile_with_state(global.editor.object_empty)
// 2D array 
global.held_tile_array = []
global.held_tile_offset = [0, 0]

global.music_names = ["", "msc_001", "msc_dungeon_wings", "msc_beecircle", "msc_dungeongroove", "msc_013",
	"msc_gorcircle_lo", "msc_levcircle", "msc_escapewithfriend", "msc_cifcircle", "msc_006", "msc_beesong", "msc_themeofcif",
	"msc_monstrail", "msc_endless", "msc_stg_extraboss", "msc_rytmi2", "msc_test2", "msc_voidpiano", "msc_finalapproach", "msc_universe",
	"snd_ev_music_judgment_jingle", "snd_ev_music_determined_descent", "snd_ev_music_tamarind", "snd_ev_music_darkroom",
	"snd_ev_music_hadean"]

// true when level being edited is from a pack and doesn't have a file
global.editing_pack_level = false;
// properties of the level node being edited
global.editing_pack_level_properties = -1;

function reset_global_level() {
	global.level = new level_struct()
	place_default_tiles(global.level)
}
reset_global_level()
function reset_editor_variables() {
	global.selected_thing = -1;
	global.tile_mode = false
	global.selected_thing = -1 
	global.selected_placeable_num = -1
	current_list = objects_list;
	current_empty_tile = object_empty
}
reset_editor_variables()


function reset_editor_history() {
	history = [];	
}
reset_editor_history();

function copy_tile_data(tiles) {
	for (var i = 0; i < array_length(tiles); i++) {
		tiles[i] = copy_array(tiles[i])
		for (var j = 0; j < array_length(tiles[i]); j++) {
			var tile_state = tiles[i][j]
			tiles[i][j] = new tile_with_state(tile_state.tile, struct_copy(tile_state.properties))
		}
	}
	return tiles;
}

// computers have infinite memory.
function add_undo() {
	array_push(history, copy_tile_data(global.level.tiles), copy_tile_data(global.level.objects))
	if array_length(history) > 500 // will remember 250 changes before removing
		array_delete(history, 0, 2)
}

function undo() {
	static undo_sound = agi("snd_voidrod_place")
	if array_length(history) != 0 {
		array_copy(global.level.objects, 0, array_pop(history), 0, array_length(global.level.objects))
		array_copy(global.level.tiles, 0, array_pop(history), 0, array_length(global.level.tiles))
		audio_play_sound(undo_sound, 10, false)
	}
}

undo_repeat = -1
undo_repeat_frames_start = 18
undo_repeat_frames_speed = 0
undo_repeat_frames_max_speed = 10

function switch_tile_mode(new_tile_mode) {
	global.tile_mode = new_tile_mode;
	if (global.tile_mode) {
		current_list = tiles_list
		current_empty_tile = tile_pit
	}
	else {
		current_list = objects_list
		current_empty_tile = object_empty
	}
	if (global.selected_thing == thing_placeable || global.selected_thing == thing_multiplaceable) {
		global.selected_thing = -1
		global.selected_placeable_num = -1
	}
}

function get_current_placeables() {
	if global.tile_mode
		return global.level.tiles;
	return global.level.objects;
}

global.erasing = -1;
erasing_surface = surface_create(224, 144)
global.goes_sound = agi("snd_ex_vacuumgoes")



function get_menu_music_name() {
	switch (current_weekday) {
		case 0: return "snd_ev_music_astra_jam"
		case 1: return "snd_ev_music_monsday"
		case 2: return "snd_ev_music_teusday"
		case 3: return "snd_ev_music_blossom"
		case 4: return "snd_ev_music_ex_smooth"
		case 5: return "snd_ev_music_endless_void"
		default: return "snd_ev_music_stealie_feelies"
	}
}
global.menu_music = agi(get_menu_music_name())



move_curve = animcurve_get_channel(ac_play_transition, "move")
grow_curve = animcurve_get_channel(ac_play_transition, "grow")
preview_curve = animcurve_get_channel(ac_preview_curve, 0)
edit_curve = animcurve_get_channel(ac_edit_curve, 0)


preview_transition = -1
max_preview_transition = 25
preview_transition_display = noone
preview_transition_highlight = noone


function preview_level_transition(lvl, lvl_sha, display_instance) {
	global.mouse_layer = -1
	display_instance.layer = layer_get_id("HighlightedLevel")
	preview_transition = max_preview_transition
	preview_transition_display = display_instance
	preview_transition_highlight = instance_create_layer(0, 0, "LevelHighlight", agi("obj_ev_level_highlight"), {
		lvl : lvl,
		lvl_sha : lvl_sha,
		display_instance : display_instance,
		alpha : 0
	})
}

function preview_level_pack_transition(nodeless_pack, display_instance) {
	global.mouse_layer = -1
	display_instance.layer = layer_get_id("HighlightedLevel")
	preview_transition = max_preview_transition
	preview_transition_display = display_instance
	preview_transition_highlight = instance_create_layer(0, 0, "LevelHighlight", agi("obj_ev_pack_highlight"), {
		nodeless_pack : nodeless_pack,
		display_instance : display_instance,
		alpha : 0
	})
}




play_transition = -1
max_play_transition = 20
play_transition_display = noone
play_transition_surface = noone;

function play_level_transition(lvl, lvl_sha, display_instance) {
	global.level = lvl;
	global.level_sha = lvl_sha
	play_transition = max_play_transition
	play_transition_display = display_instance
	play_transition_surface = display_instance.game_surface;
	display_instance.brand = 0;
	display_instance.draw_beaten = 0;
	global.mouse_layer = -1
}

play_pack_transition_time = -1
max_play_pack_transition = 250
function play_pack_transition(nodeless_pack, display_instance, tis) {
	var pack_string = read_pack_string_from_file(nodeless_pack.save_name)
	global.pack = import_pack(pack_string)
	if global.pack.version == 1
		global.pack.save_name = nodeless_pack.save_name;
	ev_stop_music();
	global.mouse_layer = -1
	display_instance.destroy();
	play_pack_transition_time = max_play_pack_transition

	//TODO
}

edit_transition = -1
max_edit_transition = 30
edit_transition_display = noone

function edit_level_transition(lvl, display_instance) {
	global.level = lvl;
	ev_stop_music()
	edit_transition = max_edit_transition
	edit_transition_display = display_instance
	display_instance.brand = 0;
	display_instance.draw_beaten = 0;
	global.mouse_layer = -1
}

edit_pack_transition = -1
max_edit_pack_transition = 1
edit_pack_transition_display = noone

function edit_level_pack_transition(nodeless_pack, display_instance) {
	var pack_string = read_pack_string_from_file(nodeless_pack.save_name)
	var pack = import_pack(pack_string)
	pack.save_name = nodeless_pack.save_name;
	room_goto(agi("rm_ev_pack_editor"))
	
	global.pack = pack;
	edit_pack_transition = max_edit_pack_transition
	edit_pack_transition_display = display_instance
	display_instance.draw_beaten = 0;
	global.mouse_layer = -1
}



// used in obj_ev_level_select, is essentially the level/pack "page". we want this to be global so it persists
global.level_start = 0;


global.online_mode = false;


get_levels = noone
validate_levels = noone
online_levels_str = noone
get_version = noone
	
global.online_levels = []
function try_update_online_levels() {
	get_levels = http_get(global.server);
}
startup_timeout = -1;

function request_version_string() {
	get_version = http_get(global.server + "/version")
}

global.key_level_map = ds_map_create()
global.level_key_map = ds_map_create()

function add_level_key(key, level_save_name) {
	ds_map_add(global.key_level_map, key, level_save_name)
	ds_map_add(global.level_key_map, level_save_name, key)
}
function remove_level_key(level_save_name) {
	var key = ds_map_find_value(global.level_key_map, level_save_name)
	ds_map_delete(global.key_level_map, key)
	ds_map_delete(global.level_key_map, level_save_name)
}
function on_server_validate_startup(valid_str) {
	ds_map_clear(global.level_key_map)
	var arr_ind = 0;
	for (var i = 1; i <= string_length(valid_str); i++) {
		var char = string_char_at(valid_str, i)
		if (char == "0") {
			// really no need to do that
			//file_delete(global.levels_directory + uploaded_levels[arr_ind] + ".key")
			array_delete(uploaded_keys, arr_ind, 1)
			array_delete(uploaded_levels, arr_ind, 1)
		}
		else
			arr_ind++;
	}
	for (var i = 0; i < array_length(uploaded_keys); i++) {
		add_level_key(uploaded_keys[i], uploaded_levels[i])	
	}
}

has_been_to_pretitle = false
function on_startup_finish() {
	get_levels = noone;
	validate_levels = noone;
	startup_timeout = 0;
	audio_play_sound(agi("snd_ev_mark_placechanger"), 10, false, 1, 0, 1.2)
	if !has_been_to_pretitle {
		room_goto(agi("rm_ev_pretitle"))
		has_been_to_pretitle = true;	
	}
	else
		room_goto(agi("rm_ev_menu"))
}



global.beaten_levels_map = ds_map_create()
function read_beaten_levels() {
	ds_map_clear(global.beaten_levels_map)
	if !global.is_merged
		return;
	if !file_exists(global.levels_directory + "beaten_levels.txt")
		return;
	var file = file_text_open_read(global.levels_directory + "beaten_levels.txt")
	
	var arr = []
	while (!file_text_eof(file)) {
		array_push(arr, file_text_readln(file));
	}
	
	for (var i = 0; i < array_length(arr); i++) {
		arr[i] = string_replace(arr[i], "\n", "")
		arr[i] = string_replace(arr[i], "\r", "")
	
		var split = ev_string_split(arr[i], "|")
		var value;
		var key;
		if array_length(split) == 2 {
			key = split[0]	
			value = int64_safe(split[1], 1)
		}
		else {
			key = arr[i]
			value = 1;
		}
		
		ds_map_add(global.beaten_levels_map, key, value);
	}
	file_text_close(file)
}
function save_beaten_levels() {	
	var str = ""
	
	var size = ds_map_size(global.beaten_levels_map);
	var key = ds_map_find_first(global.beaten_levels_map);
	if (is_undefined(key))
		return;
	var value = ds_map_find_value(global.beaten_levels_map, key)		
	str += key + "|" + string(value);
	
	for (var i = 0; i < size - 1; i++;) {
		key = ds_map_find_next(global.beaten_levels_map, key);
		value = ds_map_find_value(global.beaten_levels_map, key)		
		str += ("\n" + key + "|" + string(value))
	}
	var file = file_text_open_write(global.levels_directory + "beaten_levels.txt")
	file_text_write_string(file, str)
	file_text_close(file)
}


global.there_is_a_newer_version = false;
global.newest_version = "0.90";

global.startup_room = agi("rm_ev_startup")
global.playtesting = false;

spin_surface = surface_create(16, 16)

stupid_sprite_i_can_only_delete_later_lest_the_cube_shall_whiten = noone

spin_time_h = 0
spin_time_v = 0;

global.death_count = 0
global.turn_frames = 0
global.death_frames = -1

global.instance_touching_mouse = noone;
global.happenings = ds_map_create();

if global.is_merged {
	// the universe object is modified to not draw anything unless global.level.theme == level_themes.universe
	universe_instance = instance_create_depth(-16, -16, 1250, agi("obj_universe"))
	
	// this sprite also has no hitbox, unlike the original which would cover most of the screen
	universe_instance.sprite_index = agi("spr_ev_universe_no_flashbang");
}
function get_universe_instance() {
	if !global.is_merged
		return noone;
	return universe_instance;
}


