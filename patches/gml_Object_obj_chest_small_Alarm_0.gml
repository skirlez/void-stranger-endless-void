// TARGET: LINENUMBER_REPLACE
// 30
if ((global.stranger != 99))		
// TARGET: LINENUMBER_REPLACE
// 41
if ((global.stranger != 99))		
// TARGET: LINENUMBER_REPLACE
// 52
if ((global.stranger != 99))
// TARGET: LINENUMBER
// 111
else if (contents == 495)
{
    ds_grid_set(obj_inventory.ds_equipment, 0, 4, 1)
    global.collect_swapper = 1
}
after_chest_opened()
