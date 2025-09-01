event_inherited()

if time != 0
	exit
if (global.online_mode) {
	time = 20
	global.mouse_layer++;
	new_window(0, 0, agi("obj_ev_refresh_window"))
}
else
	agi("obj_ev_level_select").on_level_update();