#macro BRANEFUCK_MEMORY_AMOUNT 230

enum branefuck_operation_status {
	stay,
	move,
	done,
}


function compile_branefuck(program) {
	var instructions = [];
	var bracket_index_map = ds_map_create();
	
	var i = 0;
	while (i < array_length(program)) {
		switch (program[i]) {
			case "<": 
				var ret = get_bf_multiplier(program, i);
				ret.mult %= BRANEFUCK_MEMORY_AMOUNT;
				array_push(instructions, {
					operation : function (state) {
						state.pointer -= amount;
						if (state.pointer < 0)
							state.pointer += BRANEFUCK_MEMORY_AMOUNT;
						return branefuck_operation_status.move;
					},
					amount : ret.mult
				});
				i += ret.offset + 1;
				break;
			case ">":
				var ret = get_bf_multiplier(program, i);
				ret.mult %= BRANEFUCK_MEMORY_AMOUNT;
				array_push(instructions, {
					operation : function (state) {
						state.pointer += amount;
						if (state.pointer >= BRANEFUCK_MEMORY_AMOUNT)
							state.pointer -= BRANEFUCK_MEMORY_AMOUNT;
						return branefuck_operation_status.move;
					},
					amount : ret.mult
				});
				i += ret.offset + 1;
				break;
			case "+":
				var ret = get_bf_multiplier(program, i);
				array_push(instructions, {
					operation : function (state) {
						state.memory[@ state.pointer] += amount;
						return branefuck_operation_status.move;
					},
					amount : ret.mult
				});
				i += ret.offset + 1;
				break;
			case "-":
				var ret = get_bf_multiplier(program, i);
				array_push(instructions, {
					operation : function (state) {
						state.memory[@ state.pointer] -= amount;
						return branefuck_operation_status.move;
					},
					amount : ret.mult
				});
				i += ret.offset + 1;
				break;
			case "[":
				var j = i;
				var stack = 1;
				while (j < array_length(program)) {
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
					return "No matching ] for [ at index " + string(i);
				
				ds_map_set(bracket_index_map, i, array_length(instructions))
				array_push(instructions, {
					operation : bf_square_bracket_open,
					close : j
				});
				i++;
				break;
			case "]":
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
					return "No matching [ for ] at index " + string(i);
				
				ds_map_set(bracket_index_map, i, array_length(instructions))
				array_push(instructions, {
					operation : bf_square_bracket_close,
					open : j
				});
				i++;
				break;
			case ".":
				array_push(instructions, {
					operation : function() {
						return branefuck_operation_status.done;	
					}
				});
				i++;
				break;
			case "?":
				array_push(instructions, {
					operation : function(state) {
						with (state) {
							memory[@ pointer] = sign(memory[pointer])
							return branefuck_operation_status.move;
						}
					}
				});
				i++;
				break;
			case "#":
				var missing_hash_error = "Call command (#) found without a matching call command (#) afterwards at index "
				var func = "";
				i++;
				if i >= array_length(program)
					return missing_hash_error + string(i);
				while (program[i] != "#") {
					func += program[i];
					i++;
					if i >= array_length(program)
						return missing_hash_error + string(i);
				}
				
				if ds_map_exists(global.branefuck_command_functions, func) {
					array_push(instructions, {
						operation : function(state) {
							func(state.memory, state.pointer, state.executer);
							return branefuck_operation_status.move;
						},
						func : global.branefuck_command_functions[? func]
					});
				}
				else {
					return "Nonexistent command " + func;
				}
				i++;
				break;
			case "^":
				array_push(instructions, {
					operation : function (state) {
						with (state) {
							global.branefuck_persistent_memory[@ pointer] = temporary_memory[pointer];
							memory = global.branefuck_persistent_memory;
						}
						return branefuck_operation_status.move;
					}
				});
				i++;
				break;
			case "v":
			case "V":
				array_push(instructions, {
					operation : function (state) {
						with (state) {
							temporary_memory[@ pointer] = global.branefuck_persistent_memory[pointer];
							memory = temporary_memory;
						}
						return branefuck_operation_status.move;
					}
				});
				i++;
				break;
			case ",":
				var missing_input_error = "Input command (,) found without a matching input command (,) afterwards at index "
				var expression = "";
				i++;
				if i >= array_length(program)
					return missing_input_error + string(i);
				while (program[i] != ",") {
					expression += program[i];
					i++;
					if i >= array_length(program)
						return missing_input_error + string(i);
				}
				array_push(instructions, {
					operation : function (state) {
						with (state) {
							memory[@ pointer] = evaluate_expression(other.expression, temporary_memory, executer);
						}
						return branefuck_operation_status.move;
					},
					expression : expression
				});
				i++;
				break;
			case ";":
				i++;
				do {
					i++;
					if i >= array_length(program)
						break;
				} until (program[i] == "\n");
				i++;
				break;
			default:
				i++;
		}
		
	}
	
	// pass over instructions, if they're brackets, correct their open/close indices to
	// use instruction index instead of character index
	for (var i = 0; i < array_length(instructions); i++) {
		var instruction = instructions[i];
		if instruction.operation == bf_square_bracket_open {
			instruction.close = ds_map_find_value(bracket_index_map, instruction.close)
		}
		else if instruction.operation == bf_square_bracket_close {
			instruction.open = ds_map_find_value(bracket_index_map, instruction.open)
		}
	}
	ds_map_destroy(bracket_index_map)
	return instructions;
}
enum branefuck_execution_status {
	ok,
	error
}
function execute_branefuck(instructions) {
	static temporary_memory = array_create(BRANEFUCK_MEMORY_AMOUNT)
	for (var i = 0; i < BRANEFUCK_MEMORY_AMOUNT; i++)
		temporary_memory[i] = int64(0);	
	var state = {
		instructions : instructions,
		memory : temporary_memory,
		temporary_memory : temporary_memory,
		pointer : 0,
		instruction_pointer : 0,
		executer : id,
	}
	var count = 0;
	while (state.instruction_pointer < array_length(instructions)) {
		count++;
		if count > 50000 {
			return { 
				status: branefuck_execution_status.error,
				summary : "BF code ran for too long!",
				log : "BF code ran for too long!",
			};
		}
		try {
			with (instructions[state.instruction_pointer]) {
				var status = operation(state);
				if status == branefuck_operation_status.move
					state.instruction_pointer++;
				else if status == branefuck_operation_status.done
					return state.memory[state.pointer];
			}
		}
		catch (e) {
			return { 
				status: branefuck_execution_status.error,
				summary : "BF execution error!",
				log : "Branefuck execution error: " + e
			};
		}
	}
	return { 
		status: branefuck_execution_status.ok,
		value : state.memory[state.pointer] 
	};
}



function evaluate_expression(expr, temporary_memory, executer) {
	var read_base = read_string_until(expr, 1, ":");
	var base_name = read_base.substr;
	var i = 1 + read_base.offset + 1;
	
	var remainder = string_copy(expr, i, string_length(expr) - i + 1);

	var base;
	if base_name == "g" || base_name == "global"
		base = global;
	else if base_name == "s" || base_name == "self" || base_name == "id" {
		if executer.object_index == agi("obj_ev_pack_branefuck_node") {
			throw $"Branefuck node tried to access {base_name} (there is no {base_name})"
		}
		base = executer.add_inst;
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
			throw $"Invalid string index {vari_name}";
		}
		
		var index = int64(vari_name);
		if index > string_length(base) {
			throw $"String index too big {vari_name} ({vari_name} >= {string_length(base)})"
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



function execute_branefuck_im_old(program, error_value) {
	static temporary_memory = array_create(BRANEFUCK_MEMORY_AMOUNT)
	for (var i = 0; i < BRANEFUCK_MEMORY_AMOUNT; i++)
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
				ret.mult %= BRANEFUCK_MEMORY_AMOUNT;
				pointer -= ret.mult;
				if (pointer < 0)
					pointer += BRANEFUCK_MEMORY_AMOUNT;
				i += ret.offset + 1;
				break;
			case ">":
				var ret = get_bf_multiplier(program, i)
				pointer = (pointer + ret.mult) % BRANEFUCK_MEMORY_AMOUNT;
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
				memory[@ pointer] = evaluate_expression(expression, temporary_memory, id);
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