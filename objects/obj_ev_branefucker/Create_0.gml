
program = string_to_array(program_str)
instructions = compile_branefuck(program);
if is_string(instructions) {
	with (add_inst)
		event_perform(ev_other, ev_user1)
	instance_destroy(id)
	ev_notify("Branefuck compilation error!")
	log_error("Branefuck compilation error: " + instructions)
}



if string_is_int(destroy_value_str)
	destroy_value = int64(destroy_value_str)
else
	destroy_value = ""
// statue will never destroy if destroy value isn't a number