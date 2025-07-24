if global.is_merged {
	if (!instance_exists(add_inst)
			|| array_length(program) == 0)
		return;

	global.add_current_x = add_inst.x div 16
	global.add_current_y = add_inst.y div 16
}



var result = execute_branefuck(instructions)
if result.status == branefuck_execution_status.error {
	ev_notify(result.summary)
	log_info(result.log)	
	with (add_inst)
		event_perform(ev_other, ev_user1)
	instance_destroy(id)
	exit;
}
if (is_int64(destroy_value) && result.value == destroy_value) {
	with (add_inst)
		event_perform(ev_other, ev_user1)
	instance_destroy(id)	
}
