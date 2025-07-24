function bf_square_bracket_open(state) {
	with (state) {
		if memory[pointer] == 0
			instruction_pointer = other.close;
		return branefuck_operation_status.move;
	}
}
function bf_square_bracket_close(state) {
	with (state) {
		if memory[pointer] == 0 {
			return branefuck_operation_status.move;
		}
		else {
			instruction_pointer = other.open;
			return branefuck_operation_status.stay;
		}
	}
}
