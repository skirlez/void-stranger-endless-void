event_inherited();

image_index = !image_index;
global.online_mode = image_index

if (level_select_instance == noone)
	exit


level_select_instance.switch_internet_mode(global.online_mode);