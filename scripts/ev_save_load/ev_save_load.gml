function ev_save() {
	ini_open(global.save_directory + "ev_options.ini")
	ini_write_string("options", "username", global.author.username)
	ini_write_string("options", "brand", global.author.brand)
	ini_write_string("options", "server_ip", global.server_ip)
	ini_write_string("options", "server_port", global.server_port)
	ini_write_string("options", "stranger", global.stranger)
	
	ini_write_string("options", "memory", global.memory_style)
	ini_write_string("options", "wings", global.wings_style)
	ini_write_string("options", "blade", global.blade_style)
	
	ini_write_string("options", "should_log", global.should_log_udp)
	ini_write_string("options", "logging_ip", global.logging_ip)
	ini_write_string("options", "logging_port", global.logging_port)
	
	ini_write_string("options", "disable_3d_cube_bs", global.disable_3d_cube_bs)
	
	ini_write_string("stats", "grube", global.highest_grube_stack)
	ini_write_string("misc", "tis_pack_button", global.tis_pack_button)
	
	ini_close()
}
function ev_load() {
	ini_open(global.save_directory + "ev_options.ini")
	global.author.username = ini_read_string("options", "username", "Anonymous")
	global.author.brand = int64(ini_read_string("options", "brand", 0))
	global.server_ip = ini_read_string("options", "server_ip", "http://skirlez.com")
	
	global.server_port = ini_read_string("options", "server_port", 443)
	global.stranger = ini_read_real("options", "stranger", 0)
	global.memory_style = ini_read_real("options", "memory", 0)
	global.wings_style = ini_read_real("options", "wings", 0)
	global.blade_style = ini_read_real("options", "blade", 0)
	global.highest_grube_stack = ini_read_real("stats", "grube", 1)
	global.seen_intro = true;
	global.should_log_udp = ini_read_real("options", "should_log", false)
	global.logging_ip = ini_read_string("options", "logging_ip", "localhost")
	global.logging_port = ini_read_real("options", "logging_port", 1235)
	global.disable_3d_cube_bs = ini_read_real("options", "disable_3d_cube_bs", false)
	global.tis_pack_button = ini_read_real("misc", "tis_pack_button", false)
	
	ini_close()
	ev_update_vars()
}

function get_folder_and_file_names(location) {
	var filename_start = string_length(location);
	for (var i = string_length(location); i >= 1; i--) {
		if string_char_at(location, i) == "/"
			break;
		filename_start = i;
	}
	var foldername = string_copy(location, 1, filename_start - 1)
	var filename = string_copy(location, filename_start, string_length(location) - filename_start + 1)
	return { foldername : foldername, filename : filename }
}
function read_file_registry() {
	var registry_location = global.save_directory + "file_registry.json"
	var file = file_text_open_read(registry_location)
	if file == -1 {
		return {};	
	}
	var registry_string = file_text_read_string(file);
	file_text_close(file);
	
	return json_parse(registry_string);	
}
function write_file_registry(registry) {
	var registry_location = global.save_directory + "file_registry.json"
	var file = file_text_open_write(registry_location)
	if file == -1
		return false;	
	var registry_string = json_stringify(registry, false)
	file_text_write_string(file, registry_string)
	file_text_close(file);
}
function add_to_file_registry(registry, location) {
	var names = get_folder_and_file_names(location);
	var folder;
	if !variable_struct_exists(registry, names.foldername)
		registry[$ names.foldername] = {};
	folder = registry[$ names.foldername];
	if !variable_struct_exists(folder, names.filename) {
		folder[$ names.filename] = true;
		write_file_registry(registry)
	}
}
function delete_from_file_registry(registry, location) {
	var names = get_folder_and_file_names(location);
	if variable_struct_exists(registry, names.foldername) {
		var folder = registry[$ names.foldername];
		variable_struct_remove(folder, names.filename);	
		write_file_registry(registry)
	}
}
function ev_update_vars() {
	var prefix = "";
	if !string_starts_with(global.server_ip, "http://") && !string_starts_with(global.server_ip, "https://") {
		prefix = "http://"
	}
	global.server = $"{prefix}{global.server_ip}:{global.server_port}/voyager"
	
	var ip_without_http_prefix;
	if string_starts_with(global.server_ip, "https://") {
		ip_without_http_prefix = string_delete(global.server_ip, 1, string_length("https://"))
	}
	else if string_starts_with(global.server_ip, "http://") {
		ip_without_http_prefix = string_delete(global.server_ip, 1, string_length("http://"))
	}
	else
		ip_without_http_prefix = global.server_ip
	var folder;
	if global.server_port == 3000
		folder = string_lettersdigits(ip_without_http_prefix);
	else {
		folder = $"{string_lettersdigits(ip_without_http_prefix)}_{global.server_port}";
	}
	global.levels_directory = global.save_directory + folder + "/levels/"
	global.packs_directory = global.save_directory + folder + "/packs/"
	if (global.is_merged)
		agi("scr_menueyecatch")(0)
	
	if global.logging_socket != noone {
		network_destroy(global.logging_socket)
		global.logging_socket = noone;	
	}
	if global.should_log_udp {
		global.logging_socket = network_create_socket(network_socket_udp)
		log_info($"EV Starting to log on port {global.logging_port}")
	}

}

function save_level(lvl) {
	var str = export_level(lvl)
	var location = global.levels_directory + lvl.save_name + "." + level_extension;
	var file = file_text_open_write(location)
	if (file == -1)
		return false;
	file_text_write_string(file, str)
	file_text_close(file)
	if global.need_file_registry {
		add_to_file_registry(global.file_registry, location)
	}
	return true;
}
function delete_level(save_name) {
	var location = global.levels_directory + save_name + "." + level_extension
	file_delete(location)
	if global.need_file_registry {
		delete_from_file_registry(global.file_registry, location)
	}
}

function save_pack(pack) {
	var str = export_pack(pack)
	var file = file_text_open_write(global.packs_directory + pack.save_name + "." + pack_extension)
	if (file == -1)
		return false;
	file_text_write_string(file, str)
	file_text_close(file)
	if pack.password_brand != 0 {
		save_pack_password(pack)
	}
	
	return true;
}
function delete_pack(save_name) {
	file_delete(global.packs_directory + save_name + "." + pack_extension)
	file_delete(global.packs_directory + save_name + "." + pack_password_extension)
}

function save_pack_password(pack) {
	var file = file_text_open_write(global.packs_directory + pack.save_name + "." + pack_password_extension)
	if (file == -1)
		return false;
	file_text_write_string(file, string(pack.password_brand))
	file_text_close(file)
}
function load_pack_password(pack) {
	var file = file_text_open_read(global.packs_directory + pack.save_name + "." + pack_password_extension)
	if (file == -1)
		return int64(0);
	var brand_string = file_text_read_string(file)
	file_text_close(file)
	return int64_safe(brand_string, 0);
}

function pack_progress_exists(save_name) {
	return file_exists(global.packs_directory + save_name + "." + pack_save_extension)
}
function delete_pack_progress(save_name) {
	file_delete(global.packs_directory + save_name + "." + pack_save_extension)
}

function save_pack_progress(current_level_name) {
	static inv = agi("obj_inventory")
	var save = create_pack_save_struct(current_level_name)
	var save_string = json_stringify(save, false)
	var file = file_text_open_write(global.packs_directory + global.pack.save_name + "." + pack_save_extension)
	if (file == -1)
		return false;
	file_text_write_string(file, save_string)
	file_text_close(file)
	return true;
}

function load_pack_progress(save_name) {
	var file = file_text_open_read(global.packs_directory + save_name + "." + pack_save_extension)
	if (file == -1)
		return noone;
	var save_string = file_text_read_string(file)
	file_text_close(file)
	try {
		return json_parse(save_string);
	}
	catch (e) {
		ev_notify("Failed to parse save!")
		var file = file_text_open_write($"{global.packs_directory}backup_error{irandom_range(10000, 99999)}.{pack_save_extension}")
		if (file == -1)
			return noone;
		file_text_write_string(file, save_string)
		file_text_close(file)
		
		return noone;
	}
}

function save_pack_highscores(save_name, json) {
	var str = json_stringify(json);
	var file = file_text_open_write(global.packs_directory + save_name + "." + pack_highscore_extension)
	if (file == -1)
		return false;
	file_text_write_string(file, str)
	file_text_close(file)
	return true;
}

function load_pack_highscores(save_name) {
	var file = file_text_open_read(global.packs_directory + save_name + "." + pack_highscore_extension)
	var json;
	
	if (file == -1) {
		json = {}
	}
	else {
		var save_string = file_text_read_string(file)
		file_text_close(file)
		try {
			json = json_parse(save_string);	
		}
		catch (e) {
			json = {};
		}
	}
	if !variable_struct_exists(json, "scores")
		json.scores = []
	if !variable_struct_exists(json, "times")
		json.times = [];
	return json;
}

function apply_pack_save(save) {
	static inv = agi("obj_inventory")
	static player = agi("obj_ev_pack_player")
	global.branefuck_persistent_memory = save.persistent_memory;
	var track = agi(save.music);
	if track != -1 {
		ev_play_music(agi(save.music), true, true)
	}
	// TODO: remove these, temporary
	if !variable_struct_exists(save, "total_locusts_collected")
		save.total_locusts_collected = 0
	if !variable_struct_exists(save, "death_count")
		save.death_count = 0
	if !variable_struct_exists(save, "play_time")
		save.play_time = 0
	if !variable_struct_exists(save, "locust_count")
		save.locust_count = 0
	if !variable_struct_exists(save, "pack_memories")
		save.pack_memories = []
	if !variable_struct_exists(save, "palette")
		save.palette = global.s_g_pal
	
	agi("set_palette")(save.palette);
		
	ds_grid_set(inv.ds_player_info, 1, 1, save.locust_count)
	ev_prepare_level_burdens(save.burdens);
	for (var i = 0; i < array_length(save.pack_memories); i++) {
		ds_map_set(player.pack_memories, save.pack_memories[i], 1)
	}
	for (var i = 0; i < array_length(save.visited_levels); i++) {
		ds_map_set(player.visited_levels, save.visited_levels[i], 1)
	}
	player.play_time = save.play_time
	player.total_locusts_collected = total_locusts_collected;
	
	global.death_count = save.death_count
	
	function find_level_node_state_with_name(node_state, name, explored_states_map) {
		static level_node = global.pack_editor.level_node
		if (ds_map_exists(explored_states_map, node_state))
			return noone;
		if node_state.node == level_node {
			if node_state.properties.level.name == name
				return node_state;
		}
		ds_map_set(explored_states_map, node_state, 0)
		
		for (var i = 0; i < array_length(node_state.exits); i++) {
			var state = find_level_node_state_with_name(node_state.exits[i], name, explored_states_map)
			if state != noone
				return state;
		}
		return noone;
	}
	var map = ds_map_create();
	var target_name = base64_decode(save.level_name)
	var first_state = noone;
	for (var i = 0; i < array_length(global.pack.starting_node_states); i++) {
		var node_state = find_level_node_state_with_name(global.pack.starting_node_states[i], target_name, map)
		if (node_state != noone) {
			first_state = node_state
			log_info($"Found level from save with name {target_name}")
			break;	
		}
	}
	ds_map_destroy(map)
	
	
	
			
	if first_state == noone {
		log_error($"Save existed, but could not find node with name {save.level_name}."
			+ "Sadly choosing root node.")
		first_state = global.pack.starting_node_states[0];
	}
	return first_state;
}

function create_pack_save_struct(current_level_name) {
	static inv = agi("obj_inventory")
	static player = agi("obj_ev_pack_player")
	return {
		level_name : base64_encode(current_level_name),
		locust_count : ds_grid_get(inv.ds_player_info, 1, 1),
		total_locusts_collected : player.total_locusts_collected,
		music : audio_exists(global.music_file) ? audio_get_name(global.music_file) : "",
		persistent_memory : global.branefuck_persistent_memory,
		death_count : global.death_count,
		visited_levels : ds_map_keys_to_array_fix(player.visited_levels),
		pack_memories : ds_map_keys_to_array_fix(player.pack_memories),
		palette : global.s_g_pal,
		play_time : player.play_time + (current_time - player.start_time),
		burdens : [ds_grid_get(inv.ds_equipment, 0, 0) != 0,
					ds_grid_get(inv.ds_equipment, 0, 1) != 0,
					ds_grid_get(inv.ds_equipment, 0, 2) != 0,
					ds_grid_get(inv.ds_player_info, 10, 2) != 4,
					ds_grid_get(inv.ds_equipment, 0, 4) != 0],
	}
}
