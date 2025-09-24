function ev_reset_locusts() {
	static inv = agi("obj_inventory");
	ds_grid_set(inv.ds_player_info, 0, 1, 1) // display locusts
	ds_grid_set(inv.ds_player_info, 1, 1, 0) // Locust count
}

function ev_set_play_variables() {
	static inv = agi("obj_inventory");
	
	// idk what these do
	global.memory_backup = 0
	global.wings_backup = 0
	global.blade_backup = 0	
    global.swapper_backup = 0

	// Flags dictating if you got the Add version of each burden
	ds_grid_set(inv.ds_player_info, 15, 0, 0) 
	ds_grid_set(inv.ds_player_info, 15, 1, 0)
	ds_grid_set(inv.ds_player_info, 15, 2, 0)
	ds_grid_set(inv.ds_player_info, 15, 3, 0)
	
	ev_reset_locusts()
	
	// stops the player from doing the blink animation when starting level
	global.player_blink = 0
	global.death_count = 0
}

function ev_prepare_level_burdens(array = []) {
	static inv = agi("obj_inventory");
	ds_grid_set(inv.ds_equipment, 0, 0, 0)
	ds_grid_set(inv.ds_equipment, 0, 1, 0)
	ds_grid_set(inv.ds_equipment, 0, 2, 0)
	ds_grid_set(inv.ds_player_info, 10, 2, 4)
	ds_grid_set(inv.ds_equipment, 0, 4, 0)
	if array_length(array) == 5 {
		if (array[0])
			ds_grid_set(inv.ds_equipment, 0, 0, 1)
		if (array[1])
			ds_grid_set(inv.ds_equipment, 0, 1, 2)
		if (array[2])
			ds_grid_set(inv.ds_equipment, 0, 2, 3)
		if (array[3])
			ds_grid_set(inv.ds_player_info, 10, 2, 999)
		if (array[4])
			ds_grid_set(inv.ds_equipment, 0, 4, 1)
	}
}

function ev_prepare_level_visuals(level) {
	if level.theme == level_themes.universe
		global.universe = 1;
	else
		global.universe = 0;
	
	if level.theme == level_themes.white_void
		global.floorvanish = 1;
	else
		global.floorvanish = 0;
}

