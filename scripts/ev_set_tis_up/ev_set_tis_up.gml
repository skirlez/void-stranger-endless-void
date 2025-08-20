function ev_set_tis_up() {
	// TODO: check how many of these variables we can remove without it breaking.
	// I Love doing that
	
	global.cc_state = 1
	global.cc_score = 0
	global.cc_multiplier = 1
	global.cc_chain = 10
	global.cc_cat = "ABCDEFGHI"
	global.cc_catscore = 1280
	global.cc_music_state = 0
	global.infinity_check = 0
	global.voidrod_get = true
	global.voider = true
	global.brane_error = 0
	global.cif_destroy = 0
	global.cantsave = false
	ds_grid_set(agi("obj_inventory").ds_player_info, 12, 2, true)
	instance_create_layer(x, y, "Effects", asset_get_index("obj_cc_check"))
	with (agi("obj_cc_check"))
	{
		check_ms = 0
		check_timelimit = timelimit_value
		advance_music = 0
		check_score = 0
		check_state = 1
		global.cc_timercounter = 2
		global.luckylocust = 1
		global.cc_medalstate = 2
		global.cc_medalcounter = 0
		global.cc_score = 0
		global.cc_multiplier = 1
		global.cc_chain = 10
		global.locust = true

		ds_grid_set(agi("obj_inventory").ds_player_info, 22, 1, 999)
		ds_grid_set(agi("obj_inventory").ds_player_info, 16, 0, 3)
		ds_grid_set(agi("obj_inventory").ds_player_info, 18, 1, 2)
		ds_grid_set(agi("obj_inventory").ds_player_info, 11, 1, 1)
		ds_grid_set(agi("obj_inventory").ds_player_info, 11, 0, 1)
		ds_grid_set(agi("obj_inventory").ds_player_info, 17, 3, 1)
		ds_grid_set(agi("obj_inventory").ds_player_info, 20, 0, 2)
		starting_kills = ds_list_find_value(agi("obj_inventory").ds_rcrds, 9)
		starting_hits = ds_list_find_value(agi("obj_inventory").ds_rcrds, 5)
	}
}