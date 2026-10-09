event_inherited()
if (level_or_save_name == noone)
	exit



global.mouse_layer++;
new_window(12, 6, agi("obj_ev_upload_window"), {
	layer_num : global.mouse_layer,
	level_or_save_name : level_or_save_name,
	is_pack : is_pack,
})

