event_inherited()
if can_use {
	if room == global.level_room
		ev_leave_level(true)
	else if room == global.pack_level_room
		ev_leave_pack();
}