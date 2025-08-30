// Add void idol entry to burden menu

// TARGET: LINENUMBER
// 18
if (ds_grid_height(obj_menu.ds_menu_equipment) == 4) {
    with (obj_menu) {
        ds_grid_resize(ds_menu_equipment, ds_grid_width(ds_menu_equipment), 5);
        ds_grid_set(ds_menu_equipment, 2, 3, "empty_function");
        ds_grid_set(ds_menu_equipment, 4, 3, ["ON", "OFF"]);
        ds_grid_set(ds_menu_equipment, 0, 4, scrScript(7));
        ds_grid_set(ds_menu_equipment, 1, 4, 1);
        ds_grid_set(ds_menu_equipment, 2, 4, 0);
    }
}

if (ds_grid_get(obj_inventory.ds_equipment, 0, 4) != 0) {
    with (obj_menu) {
        ds_grid_set(ds_menu_equipment, 0, 3, "VOID IDOL");
        ds_grid_set(ds_menu_equipment, 1, 3, 4);
        ds_grid_set(obj_menu.ds_menu_equipment, 3, 3, 0);
    }
}
else {
    with (obj_menu) {
        ds_grid_set(ds_menu_equipment, 0, 3, "?????");
        ds_grid_set(ds_menu_equipment, 1, 3, 6);
    }
}