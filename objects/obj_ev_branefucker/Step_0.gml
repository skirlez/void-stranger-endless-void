if global.is_merged {
	if (!instance_exists(add_inst)
			|| array_length(program) == 0)
		return;

	global.add_current_x = add_inst.x div 16
	global.add_current_y = add_inst.y div 16
}


var destroy_value;
if destroy_value_str == ""
	destroy_value = "" // statue will never destroy (unless errors)
else if string_is_int(destroy_value_str)
	destroy_value = int64(destroy_value_str)
else {
	destroy_value = execute_branefuck($",g:{destroy_value_str},", 0)
}


value = execute_compiled_branefuck(instructions, destroy_value)
if (value == destroy_value) {
	with (add_inst)
		event_perform(ev_other, ev_user1)
	instance_destroy(id)	
}
