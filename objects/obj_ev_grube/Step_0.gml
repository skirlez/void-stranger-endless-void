if type == ev_grube_types.level_cube && !visible {
	if surface_exists(display_instance.game_surface) {
		var surf = surface_create(224, 144)
		surface_set_target(surf)
		draw_clear(c_black)
		draw_surface(display_instance.game_surface, 0, 0)
		surface_reset_target()
		sprite_index = sprite_create_from_surface(surf, 0, 0, 224, 144, false, false, 112, 72)	
		surface_free(surf)
		visible = true;
		instance_destroy(display_instance)
	}
}
if death_timer != -1 {
	death_timer++
	cube_size = max(cube_size_start * power(1 + 1 / (death_timer - 140), 3), 0)
	if death_timer > 140 || !audio_is_playing(death_sound) {
		
		audio_stop_sound(death_sound)
		audio_play_sound(agi("snd_ex_enemyexplosion_009"), 0, false, 0.8)
		for (var i = 0; i < array_length(window.grubes); i++) {
			var grube = window.grubes[i]
			if !instance_exists(grube)
				continue;
			if grube == id
				continue;
			
			
			

			var length = point_distance(x, y, grube.x, grube.y)
			var angle = point_direction(x, y, grube.x, grube.y)
			
			
			var cutoff = 100
			var max_force = 10;
			
			if (length > cutoff)
				continue;
			
			var effect = (cutoff - length) / cutoff;
			
			grube.phy_speed_x = dcos(angle) * effect * max_force;
			grube.phy_speed_y = -dsin(angle) * effect * max_force;
				
		}
		instance_create_layer(x, y, "Explosion", agi("obj_ev_after_erase"), {
			grube : true	
		})
		instance_destroy(id)
	}
	
	return;	
}

if ev_is_mouse_on_me() {
	if ev_mouse_pressed() {
		follow = true
		if instance_exists(agi("obj_ev_plucker")) {
			audio_play_sound(agi("snd_ev_pluck"), 10, false)	
		}
	}
	if ev_mouse_right_pressed() && room != global.pack_editor_room {
		die()
		death_timer = 50
	}
}
if ev_mouse_released() && follow {
	follow = false;
	var previousest_x = position_history[last_x_ind]
	var previousest_y = position_history[last_y_ind]
	
	phy_speed_x = (mouse_x - previousest_x) / history_size
	phy_speed_y = (mouse_y - previousest_y) / history_size

}

if follow {
	phy_speed_x = 0
	phy_speed_y = 0

	phy_speed_x = mouse_x - phy_position_x
	phy_speed_y = mouse_y - phy_position_y


}

if x < 0 || x > room_width || y > room_height
	instance_destroy(id)

for (var i = array_length(position_history) - 1; i > 1; i -= 2) {
	position_history[i - 1] = position_history[i - 3]
	position_history[i] = position_history[i - 2];
}

if follow {
	position_history[0] = mouse_x;
	position_history[1] = mouse_y;
}
position_history[0] = phy_position_x;
position_history[1] = phy_position_y;

function for_every_collision_run(func) {
	var list = ds_list_create();
	var count = instance_place_list(phy_position_x, phy_position_y, object_index, list, false)	
	for (var i = 0; i < count; i++) {
		var inst = list[| i];
		func(inst);
	}
	ds_list_destroy(list);
}
if type == ev_grube_types.enemy_cube {
	for_every_collision_run(function (instance) {
		with (instance) {
			if type == ev_grube_types.player_cube && !touched_enemy_cube {
				sprite_index = hit_sprite;
				touched_enemy_cube = true;
				audio_play_sound(agi("snd_player_damage"), 10, false);
			}
		}	
	})
}
if type == ev_grube_types.egg_cube && phy_speed > 4 {
	for_every_collision_run(function (instance) {
		with (instance) {
			if type == ev_grube_types.enemy_cube {
				instance_destroy(id)
				audio_play_sound(agi("snd_enemy_explosion"), 10, false);
				if global.is_merged {
					// leech death code
					var ienemydeath_fx = instance_create_depth(x, y, depth, agi("obj_enemydeath_fx"))
					var ideathsprite = fall_sprite;
					with (ienemydeath_fx)
					    enemy_sprite = ideathsprite
					instance_create_depth(x, y, 10, agi("obj_explosion_001"))
					instance_create_depth(x, y, 5, agi("obj_bloodtrail_fx"))
				}
			}
		}	
	})
}
