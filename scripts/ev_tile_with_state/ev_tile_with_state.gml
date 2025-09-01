global.empty_struct = { }
function tile_with_state(tile, properties = tile.properties_generator()) constructor {
	self.tile = tile
	self.properties = properties
}

// https://forum.gamemaker.io/index.php?threads/copy-struct.93707/ 
// gamemaker is dumb for not having this
function struct_copy(SS) {
	var AR = variable_struct_get_names(SS);
	
	var SS_new = {};
	for (var i = 0; i < array_length(AR); i++) {
		SS_new[$ AR[i]] = SS[$ AR[i]];
	}
	return(SS_new);
}

function struct_deep_copy(struct) {
	var arr = variable_struct_get_names(struct);
	
	var new_struct = {};
	for (var i = 0; i < array_length(arr); i++) {
		var field = arr[i];
		var value = struct[$ field];
		if is_struct(value)
			new_struct[$ field] = struct_deep_copy(value);
		else if is_array(value)
			new_struct[$ field] = copy_array(value)
		else {
			new_struct[$ field] = value
		}
	}
	return new_struct;
}