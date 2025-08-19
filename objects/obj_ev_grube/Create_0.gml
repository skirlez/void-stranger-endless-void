spin_time_h = 0
spin_time_v = 0
follow = false
history_size = 3
position_history = array_create(history_size * 2)

for (var i = 0; i < array_length(position_history) - 1; i += 2) {
	position_history[i] = x;
	position_history[i + 1] = y;
}

last_y_ind = history_size * 2 - 1;
last_x_ind = history_size * 2 - 2;

death_sound = noone
death_timer = -1;
function die() {
	phy_active = false;
	death_timer = 0
	layer = layer_get_id("Explosion")
	death_sound = audio_play_sound(agi("snd_ex_vacuumcomes"), 10, false, 1.3, 0, 1.2)
}

enum ev_grube_types {
	player_cube,
	enemy_cube,
	egg_cube,
	level_cube,
	size,
}
phy_active = false;
fix = physics_fixture_create();
cube_size = 8;
physics_fixture_set_box_shape(fix, cube_size, cube_size);
physics_fixture_set_collision_group(fix, 1);
physics_fixture_set_density(fix, 0.5);
physics_fixture_set_restitution(fix, 0.6);
physics_fixture_set_angular_damping(fix, 0.1);
physics_fixture_set_linear_damping(fix, 0.1);
physics_fixture_set_friction(fix, 0.2);


switch (type) {
	case ev_grube_types.level_cube:
		if array_length(global.online_levels) > 0 {
			// this is so jank but it's worth it
			var level_string = global.online_levels[irandom_range(0, array_length(global.online_levels) - 1)];
			var lvl = import_level(level_string);
			display_instance = instance_create_depth(-1000, -1000, 0, agi("obj_ev_display"), {
				lvl : lvl,
				no_spoiling : true,
			})
			visible = false;
			break;
		}
		type = ev_grube_types.player_cube;
	case ev_grube_types.player_cube:
		touched_enemy_cube = false;
		hit_sprite = noone;
		var stranger = choose(0, 0, 0, 0, irandom_range(1, 2));
		switch (stranger) {
			case 0:
				sprite_index = agi("spr_player_down");
				hit_sprite = agi("spr_player_hit");
				break;
			case 1:
				sprite_index = agi("spr_lil_down");
				hit_sprite = agi("spr_lil_hit");
				break;
			case 2:
				sprite_index = agi("spr_cif_down");
				hit_sprite = agi("spr_cif_hit");
				break;
		}
		break;
	case ev_grube_types.enemy_cube:
	
		var sprites = ["spr_cl_right", "spr_cc_down", "spr_ch", "spr_cg_idle"]
		var fall_sprites = ["spr_cl_falling", "spr_cc_falling", "spr_ch_falling", "spr_cg_falling"]
		var ind = irandom_range(0, array_length(sprites) - 1)
		sprite_index = agi(sprites[ind])
		fall_sprite = agi(fall_sprites[ind])
		break;
	case ev_grube_types.egg_cube:
		sprite_index = choose(agi("spr_boulder"), agi("spr_boulder"),  agi("spr_boulder"),
			agi("spr_smiler"), agi("spr_lamp"), agi("spr_ev_ninnie"));
		cube_size *= 1.5;
		image_xscale *= 1.5;
		image_yscale *= 1.5;
		physics_fixture_set_box_shape(fix, cube_size, cube_size);
		physics_fixture_set_restitution(fix, 0.3);
		break;
}
phy_active = true;
physics_fixture_bind(fix, id);

