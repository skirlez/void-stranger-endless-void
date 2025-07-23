// I don't think i'll even use this for the project, i just wanted to see
// what a GML implementation could look like
function optional(val = pointer_invalid) constructor {
	self.val = val;

	if (val != pointer_invalid) {
		self.get = method(self, function() {
			return val;
		});
		self.get_or_else = method(self, function(else_var) {
			return val;
		});
		self.is_empty = method(self, function() {
			return false;
		});
	}
	else {
		self.get = method(self, function() {
			throw ("Called get() on an empty optional!")
		});
		self.get_or_else = method(self, function(else_var) {
			return else_var;
		});
		self.is_empty = method(self, function() {
			return true;
		});
	}
}

function copy_array(arr) {
	if (array_length(arr) == 0)
		return [];
	arr[0] = arr[0]
	return arr;
}


function get_all_files(dir, ext) {
	var files = [];
	var file_name = string_replace(file_find_first(dir + "*." + ext, 0), "." + ext, "");
	while (file_name != "") {
		array_push(files, file_name);
		file_name = string_replace(file_find_next(),  "." + ext, "");
	}
	file_find_close(); 
	return files;
}

function ev_array_contains(arr, value) {
	for (var i = 0; i < array_length(arr); i++) {
		if (arr[@ i] == value)
			return true;
	}
	return false;
}
function ev_array_get_index(arr, value) {
	for (var i = 0; i < array_length(arr); i++) {
		if (arr[@ i] == value)
			return i;
	}
	return -1;
}
function ev_array_remove(arr, value) {
	for (var i = 0; i < array_length(arr); i++) {
		if (arr[@ i] == value) {
			array_delete(arr, i, 1);
			return;	
		}
	}
}



function ev_string_split(str, delimiter) {
	var arr = []
	var build = ""
	for (var i = 1; i <= string_length(str); i++) {
		var c = string_char_at(str, i)
		if (c == delimiter) {
			array_push(arr, build);	
			build = ""
		}
		else
			build += c;	
	}
	array_push(arr, build);	
	return arr;
}
function ev_string_split_stop(str, delimiter, max_splits) {
	var arr = []
	var build = ""
	for (var i = 1; i <= string_length(str); i++) {
		var c = string_char_at(str, i)
		if (c == delimiter) {
			array_push(arr, build);	
			if array_length(arr) == max_splits
				return arr;
			build = ""
		}
		else
			build += c;	
	}
	array_push(arr, build);	
	return arr;
}

function ev_string_split_buffer(str, delimiter, approx_average_substr_length) {
	var delimiter_ord = ord(delimiter)
	
	var size = string_length(str) + 1;
	var buf = buffer_create(size, buffer_fixed, 1);
	buffer_write(buf, buffer_string, str);
	buffer_seek(buf, buffer_seek_start, 0);
	
	var arr = []
	var build = buffer_create(approx_average_substr_length, buffer_grow, 1);

	while (buffer_tell(buf) < size) {
		var c = buffer_read(buf, buffer_u8)
		if (c == delimiter_ord) {
			buffer_write(build, buffer_u8, 0)
			var substr = buffer_peek(build, 0, buffer_string)
			array_push(arr, substr);
			buffer_seek(build, buffer_seek_start, 0)
		}
		else
			buffer_write(build, buffer_u8, c)
	}
	if (buffer_tell(build) != 0) {
		buffer_write(build, buffer_u8, 0)
		var substr = buffer_peek(build, 0, buffer_string)
		array_push(arr, substr);	
	}
	buffer_delete(buf)
	buffer_delete(build)
	return arr;
}

function int64_safe(value, failsafe = 0) {
	try { 
		return int64(value);
	}
	catch (e) {
		return int64(failsafe);
	}
}

function real_safe(value, failsafe = 0) {
	try { 
		return real(value);
	}
	catch (e) {
		return real(failsafe);
	}
}

function num_to_string(num, length) {
	return string_replace(string_format(num, length, 0), " ", 0)	
}

function ds_list_to_array(list) {
	var size = ds_list_size(list);
	var arr = array_create(size)
	for (var i = 0; i < size; i++) {
		arr[i] = list[| i];	
	}
	return arr;
}

// I don't know why
function ds_map_keys_to_array_fix(map) {
	return ds_map_size(map) == 0 ? [] : ds_map_keys_to_array(map)
}
