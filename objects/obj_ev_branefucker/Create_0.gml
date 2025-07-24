
program = string_to_array(program_str)
instructions = compile_branefuck(program);
if is_string(instructions) {
	with (add_inst)
		event_perform(ev_other, ev_user1)
	instance_destroy(id)
	ev_notify("Branefuck compilation error!")
	log_error("Branefuck compilation error: " + instructions)
}
