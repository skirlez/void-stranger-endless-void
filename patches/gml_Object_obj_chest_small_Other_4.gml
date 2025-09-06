// TARGET: LINENUMBER
// 58
// Make chest opened if we already have idol
if (contents == 495 && ds_grid_get(obj_inventory.ds_equipment, 0, 4) != 0)
{
    image_speed = 1
    empty = true
}

// the following patches make chests check for equipment rather than if they specifically got the add version of the burden, which is a different flag
// (cif has those flags unset)

// TARGET: STRING
ds_grid_get(obj_inventory.ds_player_info, 15, 1) != 0> ds_grid_get(obj_inventory.ds_equipment, 0, 2) != 0

// TARGET: STRING
ds_grid_get(obj_inventory.ds_player_info, 15, 2) != 0> ds_grid_get(obj_inventory.ds_equipment, 0, 1) != 0

// TARGET: STRING
ds_grid_get(obj_inventory.ds_player_info, 15, 0) != 0> ds_grid_get(obj_inventory.ds_equipment, 0, 0) != 0 

// TARGET: STRING
ds_grid_get(obj_inventory.ds_player_info, 15, 3) != 0> ds_grid_get(obj_inventory.ds_player_info, 10, 2) != 4 



// TARGET: LINENUMBER_REPLACE
// 36
// Don't remove sword chest if we have sword

