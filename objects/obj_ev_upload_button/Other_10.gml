event_inherited()
if (lvl == noone)
	exit



global.mouse_layer++;
new_window(12, 6, agi("obj_ev_upload_window"), {
	layer_num : global.mouse_layer,
	lvl : lvl,
	is_pack : is_pack,
})

