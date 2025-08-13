event_inherited();
if !grube_mode {
	for (var i = 0; i < array_length(current_page); i++) {
		var entry = current_page[i];
		with (entry) {
			if time_until_active > 0 {
				time_until_active--;
				if time_until_active == 0 && activate_sound != noone {
					audio_play_sound(activate_sound, 10, false, 1, 0, random_range(0.8, 1.2))	
				}

			}
			else
				step();
		}
	}
	exit
}
var ypos = camera_get_view_y(view_camera[0])
if mouse_wheel_down() || ev_get_vertical_held() == 1 {
	 ypos += 6 + scroll_accel
	 scroll_accel += 0.25
}
else if mouse_wheel_up() || ev_get_vertical_held() == -1 {
	ypos -= 6 + scroll_accel
	scroll_accel += 0.25
}
else {
	scroll_accel = 0
}	

ypos = clamp(ypos, 0, 5552)

camera_set_view_pos(view_camera[0], camera_get_view_x(view_camera[0]), ypos)
grube_button.y = ypos + 30
var cache = ds_map_create();

function find_grubes_above(grube, cache) {
	if global.is_html5
		grube = grube.id;
	static grube_object = agi("obj_ev_grube")
	
	if !ds_map_exists(cache, grube) {
		var above_grube = noone
		with (grube) {
			var list = ds_list_create()
			instance_place_list(x, y - 16, grube_object, list, true);
			var arr = ds_list_to_array(list);
			ds_list_destroy(list);
			
			for (var i = 0; i < array_length(arr) && above_grube == noone; i++) {
				if (arr[i].y > grube.y)
					continue;
				if (abs(arr[i].y - grube.y) < 12)
					continue;
				if (arr[i].death_timer != -1)
					continue;
				above_grube = arr[i];
			}
			
			
		}

		if above_grube == noone || above_grube.y > grube.y {
			ds_map_add(cache, grube, 0)
			return 0;
		}
		
		var above_above_value = find_grubes_above(above_grube, cache);
		ds_map_add(cache, grube, above_above_value + 1)
		return above_above_value + 1;
	}
	return ds_map_find_value(cache, grube);

}
max_stack = 0
for (var i = 0; i < array_length(grubes); i++) {
	var grube = grubes[i];
	if !instance_exists(grube) {
		array_delete(grubes, i, 1)
		i--;
		continue;	
	}
	var value = find_grubes_above(grube, cache) + 1
	if value > max_stack
		max_stack = value;
}


ds_map_destroy(cache);

dense_check_timer--;
if dense_check_timer <= 0 &&  array_length(grubes) != 0 {
	dense_check_timer = dense_check_timer_max;
	var random_grube = grubes[irandom_range(0, array_length(grubes) - 1)]
	if random_grube.death_timer == -1 {
	
		var max_close_grubes = 8;
		var close_dist = 32;
		var close_grubes = 0;
	
		for (var i = 0; i < array_length(grubes); i++) {
			var grube = grubes[i]
			if grube == random_grube
				continue;
			if point_distance(grube.x, grube.y, random_grube.x, random_grube.y) < close_dist
				close_grubes++;
		}
		if close_grubes >= max_close_grubes {
			for (var i = 0; i < array_length(grubes); i++) {
				if grubes[i] == random_grube {
					array_delete(grubes, i, 1)
					break;	
				}
			}
			random_grube.die()
		}
	}
}

if max_stack > highest_stack && max_stack > potential_new_highest_stack {
	potential_new_highest_stack = max_stack
	timer_hold_highest_stack = timer_hold_highest_stack_max;
}
if potential_new_highest_stack != 0 {
	timer_hold_highest_stack--;
	if timer_hold_highest_stack <= 0 {
		highest_stack = potential_new_highest_stack;
		potential_new_highest_stack = 0;
	}
	if max_stack < potential_new_highest_stack {
		potential_new_highest_stack = 0;	
		timer_hold_highest_stack = 0;
	}
	
}

