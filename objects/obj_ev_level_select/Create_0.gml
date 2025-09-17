event_inherited()

enum level_selector_modes {
	// selecting levels
	levels,
	// selecting pack (still levels, since you're selecting thumbnail levels)
	packs,
	// selecting level for use in a pack
	selecting_level_for_pack
}

if mode != level_selector_modes.selecting_level_for_pack {
	var back_button = instance_create_layer(200, 16, buttons_layer, agi("obj_ev_main_menu_button"), {
		base_scale_x : 1,
		base_scale_y : 0.7,
		txt : "Back",
		room_name : "rm_ev_menu",
	});
	
	var new_button;
	if (mode == level_selector_modes.levels) {
		new_button = instance_create_layer(24, 16, buttons_layer, agi("obj_ev_executing_button"), {
			base_scale_x : 0.9,
			base_scale_y : 0.8,
			txt : "NEW",
			func : function () {
				global.editor.reset_global_level();
				global.editor.reset_editor_history();
				global.editor.reset_editor_variables();
				ev_claim_level(global.level)
				room_goto(global.editor_room)
				
			}
		});
	}
	else {
		new_button = instance_create_layer(24, 16, buttons_layer, agi("obj_ev_executing_button"), {
			base_scale_x : 0.9,
			base_scale_y : 0.8,
			txt : "NEW",
			func : function () {
				global.pack_editor.reset_global_pack();
				ev_claim_pack(global.pack)
				room_goto(agi("rm_ev_pack_editor"))	
			}
		});
	}
	

	var online_switch = instance_create_layer(112 + 29, 12, buttons_layer, agi("obj_ev_online_switch"), {
		level_select_instance : id,	
	});
	var refresh_button = instance_create_layer(112 + 56, 12, buttons_layer, agi("obj_ev_refresh"), {
		level_select_instance : id,	
	});
	add_child(back_button)
	add_child(new_button)
	// TODO remove this
	if instance_exists(online_switch)
		add_child(online_switch)
	add_child(refresh_button)
}
else {
	var back_button = instance_create_layer(200, 16, buttons_layer, agi("obj_ev_executing_button"), {
		base_scale_x : 1,
		base_scale_y : 0.7,
		txt : "Back",
		func : function () {
			instance_destroy(window);
		}
		
	});	
	add_child(back_button);
}


function level_clicked(display_inst) {
	if mode != level_selector_modes.selecting_level_for_pack {
		with (display_inst) {
			highlighted = true;	
		}
		if (other.mode == level_selector_modes.packs)
			global.editor.preview_level_pack_transition(display_inst.nodeless_pack, display_inst)
		else
			global.editor.preview_level_transition(display_inst.lvl, display_inst.lvl_sha, display_inst)
	}
	else {
		var lvl = display_inst.lvl;
		
		strip_level_for_pack(lvl)
		
		instance_destroy(id)
		
		var level_nodes = get_all_level_node_instances()
		try_level_name_and_rename(lvl, level_nodes)

		var node_state = new node_with_state(global.pack_editor.level_node,
			mouse_x - 224 * global.level_node_display_scale / 2,
			mouse_y - 144 * global.level_node_display_scale / 2,
			{
				level : lvl	
			});
		var instance = node_state.create_instance();
		instance.spawn_picked_up = true;
		instance.mouse_moving = true;
		play_pickup_sound(random_range(1, 1.05))
		expand_node_instance(instance)
		
		global.pack_editor.add_undo_action(function (args) {
			var instance = ds_map_find_value(global.pack_editor.node_id_to_instance_map, args.node_id)
			instance_destroy(instance)
		}, {
			node_id : instance.node_id,
		})
	}
	
}

function destroy_displays(except = noone) {
	for (var i = 0; i < array_length(children); i++) {
		var inst = children[i]
		if (inst.object_index == global.display_object && inst != except) { 
			array_delete(children, i, 1)
			i--;
			instance_destroy(inst)	
		}
	}
}

function get_filtered_level_indices() {
	/* Return levels filtered with the search box */
	
	if search_box.txt == "" {
		return no_filter;
	}
	
	// could be optimized (probably fine to allocate an array the same size as the levels array)
	var filtered_level_indices = [];
	var search_text = string_lower(search_box.txt);
	
	for (var i = 0; i < array_length(levels); i++) {
		var lvl_string = levels[i];
		var lvl_name = level_names[i]
		var lvl_version = get_level_version_from_string(lvl_string);
		
		if (lvl_version == -1 || lvl_version > global.latest_lvl_format)
			continue;
			
		if (search_text != "" && string_pos(search_text, string_lower(lvl_name)) == 0)
			continue;

		// You can add other filters here...
		
		
		
		array_push(filtered_level_indices, i);
	}

	return filtered_level_indices
}

function create_displays() {
	destroy_displays()
	var line = 0;
	var pos = 0

	var count = 0;
	
	filtered_level_indices = get_filtered_level_indices();
	
	if array_length(filtered_level_indices) == 0 {
		global.level_start = 0
		return;
	}

	if (global.level_start <= -1)
		global.level_start = (array_length(filtered_level_indices) - 1) div 6;
	else if (global.level_start * 6 >= array_length(filtered_level_indices))
		global.level_start = 0;
	
	var start = global.level_start * 6
	for (var i = start; i < array_length(filtered_level_indices) && count < 6; i++) {
		var level_index = filtered_level_indices[i];
		var lvl_string = levels[level_index];
		var lvl_struct = import_level(lvl_string)
		
		if mode == level_selector_modes.packs {
			var nodeless_pack = nodeless_packs[level_index];
			var display = instance_create_layer(20 + pos * 50, 40 + line * 50, "Levels", global.display_object, {
				lvl : lvl_struct,
				name : nodeless_pack.name,
				brand : nodeless_pack.author_brand,
				nodeless_pack : nodeless_pack,
				layer_num : layer_num,
				display_context : display_contexts.level_select,
				no_spoiling : true,
				image_xscale : 0.2,
				image_yscale : 0.2
			});
			add_child(display);		
		}
		else {
			if (!global.online_mode)
				lvl_struct.save_name = files[level_index]
		
			var sha = level_string_content_sha1(lvl_string)
			var beat_value;
			if ds_map_exists(global.beaten_levels_map, sha)
				beat_value = ds_map_find_value(global.beaten_levels_map, sha)
			else
				beat_value = 0;
			
			var display = instance_create_layer(20 + pos * 50, 40 + line * 50, "Levels", global.display_object, {
				lvl : lvl_struct,
				lvl_sha : sha,
				name : lvl_struct.name,
				brand : lvl_struct.author_brand,
				layer_num : layer_num,
				draw_beaten : beat_value,
				display_context : display_contexts.level_select,
				no_spoiling : true,
				image_xscale : 0.2,
				image_yscale : 0.2
			});
			add_child(display);
		}
		pos++;
		if pos > 2 {
			pos = 0
			line++;
		}
		count++;
	}	
}



search_box = instance_create_layer(112 - 30, 12, buttons_layer, agi("obj_ev_textbox"), 
{
	empty_text : "Search...",
	allow_newlines : false,
	automatic_newline : false,
	char_limit : 50,
	layer_num : layer_num,
	base_scale_x : 5,
	change_func : function () {
		agi("obj_ev_level_select").create_displays();
	}
})

search_box.depth--;
add_child(search_box)

var scroll_up = instance_create_layer(194, 61, buttons_layer, agi("obj_ev_executing_scroll_button"), {
	image_index : 1,
	func : function () {
		global.level_start -= 1
		with (agi("obj_ev_level_select")) {
			create_displays()	
		}	
	},
})
var scroll_down = instance_create_layer(194, 95, buttons_layer, agi("obj_ev_executing_scroll_button"), {
	func : function () {
		global.level_start += 1
		with (agi("obj_ev_level_select")) {
			create_displays()	
		}	
	},
});
add_child(scroll_up)
add_child(scroll_down)


function switch_internet_mode(new_mode) {
	global.level_start = 0
	if (new_mode == false) {
		levels = offline_levels 
		level_names = offline_level_names
	}
	else {
		levels = online_levels
		level_names = online_level_names	
	}
	no_filter = ev_array_create_ext(array_length(levels), function (i) {
		return i;
	})
	create_displays();
}


files = []
nodeless_packs = [];
function read_online_levels() {
	online_levels = copy_array(global.online_levels)
	online_level_names = array_create(array_length(online_levels))
	for (var i = 0; i < array_length(online_levels); i++)
		online_level_names[i] = get_level_name_from_string(online_levels[i])
}

function read_offline_levels() {
	if (mode == level_selector_modes.packs) { 
		files = get_all_files(global.packs_directory, pack_extension)
		nodeless_packs = array_create(array_length(files));
		offline_levels = array_create(array_length(files));
		offline_level_names = array_create(array_length(files));
		for (var i = 0; i < array_length(files); i++) {
			var pack_string = read_pack_string_from_file(files[i], true)
			if !is_string(pack_string) {
				array_delete(files, i, 1)
				array_delete(nodeless_packs, i, 1)
				array_delete(offline_levels, i, 1)
				array_delete(offline_level_names, i, 1)
				i--;
				continue;
			}
			var pack = import_pack_nodeless(pack_string);
			pack.save_name = files[i];
			
			nodeless_packs[i] = pack;
			offline_level_names[i] = pack.name;
			offline_levels[i] = pack.thumbnail_level
		}
		return;
	}
	files = get_all_files(global.levels_directory, level_extension)
	offline_levels = array_create(array_length(files));
	offline_level_names = array_create(array_length(files));
	for (var i = 0; i < array_length(files); i++) {
		var file = file_text_open_read(global.levels_directory + files[i] + "." + level_extension)
		var lvl_string = file_text_read_string(file)
		offline_levels[i] = lvl_string
		offline_level_names[i] = get_level_name_from_string(lvl_string);
		file_text_close(file)
	}
}

// called when refreshing, or when pasting a level
function on_level_update() {
	if (global.online_mode) {
		read_online_levels()
	}
	else {
		read_offline_levels()
	}
	switch_internet_mode(global.online_mode)
	if (!instance_exists(agi("obj_ev_level_highlight")))
		create_displays();
}


if (mode == level_selector_modes.packs || mode == level_selector_modes.selecting_level_for_pack)
	global.online_mode = false;

read_offline_levels()
if mode != level_selector_modes.selecting_level_for_pack && mode != level_selector_modes.packs
	read_online_levels()
switch_internet_mode(global.online_mode)
create_displays()

