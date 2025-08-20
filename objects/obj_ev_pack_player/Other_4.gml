if room != global.pack_level_room && room != agi("rm_cc_results") {
	instance_destroy(id)
	return;
}