// in the current version, any VS patch file with got_any_burdens in it uses this instead,
// since that function is declared inside obj_menu's create event, and right now the compiler
// freaks out about that.

// vanilla ev_got_any_burdens is patched to just call this too.

function ev_got_any_burdens() {
	with (agi("obj_inventory")) {
        if (ds_grid_get(ds_equipment, 0, 2) == 3 
				|| ds_grid_get(ds_equipment, 0, 1) == 2 
				|| ds_grid_get(ds_equipment, 0, 0) == 1
				|| ds_grid_get(ds_equipment, 0, 4) != 0)
			return true;
    }
    return false;
}