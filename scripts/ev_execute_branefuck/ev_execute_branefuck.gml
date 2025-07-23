function execute_branefuck(program, error_value) {
	static temporary_memory = array_create(ADD_STATUE_MEMORY_AMOUNT)
	for (var i = 0; i < ADD_STATUE_MEMORY_AMOUNT; i++)
		temporary_memory[i] = int64(0);	
	var memory = temporary_memory;
	
	var program_length = array_length(program);
	var pointer = 0
	var i = 0;
	var count = 0;
	while (i < program_length) {
		var command = program[i];
		count++;
		if (count > 50000) {
			ev_notify("BF code ran for too long!")
			return error_value;
		}
		switch (command) {
			case "<": 
				var ret = get_bf_multiplier(program, i)
				ret.mult %= ADD_STATUE_MEMORY_AMOUNT;
				pointer -= ret.mult;
				if (pointer < 0)
					pointer += ADD_STATUE_MEMORY_AMOUNT;
				i += ret.offset + 1;
				break;
			case ">":
				var ret = get_bf_multiplier(program, i)
				pointer = (pointer + ret.mult) % ADD_STATUE_MEMORY_AMOUNT;
				i += ret.offset + 1;
				break;
			case "+":
				var ret = get_bf_multiplier(program, i)
				memory[@ pointer] += ret.mult;
				i += ret.offset + 1;
				break;
			case "-":
				var ret = get_bf_multiplier(program, i)
				memory[@ pointer] -= ret.mult;
				i += ret.offset + 1;
				break;
			case "[":
				if (memory[pointer] == 0) {
					var j = i;
					var stack = 1;
					while (j < program_length) {
						j++;
						if (program[j] == "[")
							stack++;
						else if (program[j] == "]") {
							stack--;
							if (stack == 0)
								break;
						}
					}
					if (stack != 0)
						return error_value;
					i = j + 1;
				}
				else
					i++;
				break;
			case "]":
				if (memory[pointer] != 0) {
					var j = i;
					var stack = 1;
					while (j > 0) {
						j--;
						if (program[j] == "]")
							stack++;
						else if (program[j] == "[") {
							stack--;
							if (stack == 0)
								break;
						}
					}
					if (stack != 0)
						return error_value;
					i = j + 1;
				}
				else
					i++;
				break;
			case ".":
				return (memory[pointer])
			case "?":
				memory[@ pointer] = sign(memory[pointer])
				i++;
				break;
			case "#":
				var func = "";
				i++;
				if i >= program_length
					return error_value;
				while (program[i] != "#") {
					func += program[i];
					i++;
					if i >= program_length
						return error_value;
				}
				
				if ds_map_exists(global.branefuck_command_functions, func) {
					global.branefuck_command_functions[? func](memory, pointer, id)
				}
				i++;
				break;
			case "^":
				global.branefuck_persistent_memory[@ pointer] = temporary_memory[pointer];
				memory = global.branefuck_persistent_memory;
				i++;
				break;
			case "v":
			case "V":
				temporary_memory[@ pointer] = global.branefuck_persistent_memory[pointer];
				memory = temporary_memory;
				i++;
				break;
			case ",":
				var expression = "";
				i++;
				if i >= program_length
					return error_value;
				while (program[i] != ",") {
					expression += program[i];
					i++;
					if i >= program_length
						return error_value;
				}
				i++;
				memory[@ pointer] = evaluate_expression(expression, temporary_memory);
				break;
			case ";":
				i++;
				do {
					i++;
					if i >= program_length
						return error_value;
				} until (program[i] == "\n");
				i++;
				if i >= program_length
					return error_value;
				break;
			default:
				i++;
		}
	}
	return memory[pointer];
}

function evaluate_expression(expr, temporary_memory) {
	var read_base = read_string_until(expr, 1, ":");
	var base_name = read_base.substr;
	var i = 1 + read_base.offset + 1;
	
	var remainder = string_copy(expr, i, string_length(expr) - i + 1);

	var base;
	if base_name == "g" || base_name == "global"
		base = global;
	else if base_name == "s" || base_name == "self" || base_name == "id" {
		if object_index != agi("obj_ev_branefucker") {
			ev_notify($"(there is no {base_name})")
			ev_notify($"Branefuck node tried to access {base_name}")
			return 0;
		}
		base = add_inst;
	}
	else if base_name == "t"
		base = temporary_memory;
	else if base_name == "p"
		base = global.branefuck_persistent_memory;
	else if agi(base_name) != -1
		base = agi(base_name);
	else
		return noone;
	return evaluate_expression_recursive(remainder, base);
}
function evaluate_expression_recursive(expr, base) {
	if expr == ""
		return base;

	var read_vari = read_string_until(expr, 1, ":");
	var vari_name = read_vari.substr;
	var i = 1 + read_vari.offset + 1;
	var remainder = string_copy(expr, i, string_length(expr) - i + 1);
	if is_array(base) {
		if !string_is_uint(vari_name)
			return noone;
		return evaluate_expression_recursive(remainder, base[int64(vari_name)])
	}
	if is_string(base) {
		if !string_is_uint(vari_name) {
			ev_notify($"({vari_name})")
			ev_notify("Invalid string index")
			return noone;
		}
		
		var index = int64(vari_name);
		if index > string_length(base) {
			ev_notify($"({vari_name} >= {string_length(base)})")
			ev_notify("String index too big")
		}
		var character = string_ord_at(base, index + 1)
		
		// we know this is a number so we can return
		return character;
	}
	if is_struct(base) {
		return evaluate_expression_recursive(remainder, variable_struct_get(base, vari_name))
	}
	if object_exists(base) {
		var instance = instance_find(base, 0);
		if instance_exists(instance) {
			if (!variable_instance_exists(instance, vari_name))
				return noone;
			return evaluate_expression_recursive(remainder, variable_instance_get(instance, vari_name))
		}
		else
			return noone;
	}
	if instance_exists(base) {
		if (!variable_instance_exists(base, vari_name))
			return noone;
		return evaluate_expression_recursive(remainder, variable_instance_get(base, vari_name))
	}
	return noone;
}

// get the multiplier following this character, if it exists.
function get_bf_multiplier(program, i) {
	var num_string = "";
	i++;
	var count = 0;
	while (i < array_length(program)) {
		var read_char = program[i]
		if !is_digit(read_char)
			break;
		num_string += read_char
		i++;
		count++;
	}
	if (num_string == "")
		num_string = "1"
	var num = int64(num_string)
	return { mult : num, offset : count };
}