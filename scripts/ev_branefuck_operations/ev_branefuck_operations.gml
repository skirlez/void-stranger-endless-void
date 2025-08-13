function bf_square_bracket_open(data) {
	if memory[pointer] == 0
		instruction_pointer = data.close;
}
function bf_square_bracket_close(data) {
	if memory[pointer] != 0 {
		instruction_pointer = data.open - 1;
	}
}
function bf_input_operation(data) {
	memory[@ pointer] = evaluate_expression(data.expression, temporary_memory, executer);
}
function bf_tempmem_operation() {
	temporary_memory[@ pointer] = global.branefuck_persistent_memory[pointer];
	memory = temporary_memory;
}
function bf_persistmem_operation() {
	global.branefuck_persistent_memory[@ pointer] = temporary_memory[pointer];
	memory = global.branefuck_persistent_memory;
}
function bf_call_operation(data) {
	data.func(memory, pointer, executer);
}
function bf_sign_operation() {
	memory[@ pointer] = sign(memory[pointer])
}
function bf_out_operation() {
	instruction_pointer = array_length(instructions)
}

function bf_plus_operation(data) {
	memory[@ pointer] += data.amount;
}
function bf_minus_operation(data) {
	memory[@ pointer] -= data.amount;
}

function bf_right_operation(data) {
	pointer += data.amount;
	if (pointer >= BRANEFUCK_MEMORY_AMOUNT)
		pointer -= BRANEFUCK_MEMORY_AMOUNT;
}
function bf_left_operation(data) {
	pointer -= data.amount;
	if (pointer < 0)
		pointer += BRANEFUCK_MEMORY_AMOUNT;
}