function move_node_to_position(instance, new_x, new_y) {
	with (instance) {
		x = new_x
		y = new_y

		if (y < 0)
			y = 0
		if (y > room_height - sprite_height)
			y = room_height - sprite_height
		if (x < 0)
			x = 0
		if (x > room_width - sprite_width)
			x = room_width - sprite_width
		center_x = x + center_x_offset
		center_y = y + center_y_offset
		
		line_drawer.update()
		for (var i = 0; i < array_length(instance.connected_to_me); i++) {
			instance.connected_to_me[i].line_drawer.update()
		}
	}
}


function expand_node_instance(node_instance) {
	with (node_instance) {
		var scale_factor = (node_type == global.pack_editor.level_node) ? 1.2 : 1.3
		image_xscale = scale_x_start * scale_factor;
		image_yscale = scale_y_start * scale_factor;
		x -= (image_xscale - scale_x_start) * ((center_x - x) * 4)
		y -= (image_yscale - scale_y_start) * ((center_y - y) * 4)
		center_x_offset = center_x_offset_start * scale_factor;
		center_y_offset = center_y_offset_start * scale_factor;
		center_x = x + center_x_offset;
		center_y = y + center_y_offset;
	}
}

function contract_node_instance(node_instance) {
	with (node_instance) {
		x += (image_xscale - scale_x_start) * ((center_x - x) * 4)
		y += (image_yscale - scale_y_start) * ((center_y - y) * 4)
		image_xscale = scale_x_start;
		image_yscale = scale_y_start;
		center_x_offset = center_x_offset_start;
		center_y_offset = center_y_offset_start;
		center_x = x + center_x_offset;
		center_y = y + center_y_offset;
	}
}



function get_node_at_position(pos_x, pos_y) {
	var node_inst = instance_position(mouse_x, mouse_y, global.node_object)
	if node_inst == id
		return noone;
	return node_inst;
}
function play_pickup_sound(pitch) {
	static sounds = [agi("snd_ev_node_pickup_1"), agi("snd_ev_node_pickup_2"), agi("snd_ev_node_pickup_3")]
	audio_play_sound(sounds[irandom_range(0, array_length(sounds) - 1)], 10, false, global.pack_zoom_gain, 0, pitch)
}
function node_instance_step() {
	static root_node_obj = agi("obj_ev_pack_root")
	static not_possible_sound = agi("snd_lorddamage")
	
	if (ev_is_mouse_on_me()) {
		if unselectable
			return;
		if in_menu && global.pack_editor.selected_thing == pack_things.selector {
			if ev_mouse_pressed() {
				static node_button = agi("obj_ev_pack_node_button")
				node_button.pick(id);
				global.pack_editor.select(pack_things.nothing)
				in_menu = false;
				spawn_picked_up = true;
				mouse_moving = true;
				layer = layer_get_id("Nodes");
				
				global.pack_editor.add_undo_action(function (args) {
					var instance = ds_map_find_value(global.pack_editor.node_id_to_instance_map, args.node_id)
					instance_destroy(instance)
				}, {
					node_id : node_id,
				})
				
			}
		}
		if global.pack_editor.selected_thing == pack_things.nothing {
			if ev_mouse_pressed() {
				x_when_started_moving = x;
				y_when_started_moving = y;
				mouse_moving = true;
				play_pickup_sound(random_range(1, 1.05))
				expand_node_instance(id)
			}
			if ev_mouse_right_pressed() {
				if mouse_moving {
					mouse_moving = false;
					if !spawn_picked_up
						add_undo_position_action(node_id, x_when_started_moving, y_when_started_moving)
					spawn_picked_up = false;
					contract_node_instance(id)
					node_config();
				}
				else if max_exits == 0 {
					shake_seconds = 0.5;
					audio_play_sound(not_possible_sound, 10, false, global.pack_zoom_gain);	
				}
				else {
					static start_connect_sound = agi("snd_ev_node_start_connect")
					audio_play_sound(start_connect_sound, 10, false, global.pack_zoom_gain, 0, random_range(0.9, 1.1));	
					global.pack_editor.node_instance_connecting = id
				}
			}
		}
		else if global.pack_editor.selected_thing == pack_things.hammer {
			if ev_mouse_pressed() {
				static judgment_object = agi("obj_ev_pack_node_judgment");
				
				instance_destroy(judgment_object)
				
				if !(global.pack_editor.judging_node == id) {
					static hammer_sound = agi("snd_ev_hammer_judge")
					audio_play_sound(hammer_sound, 10, false, global.pack_zoom_gain, 0, random_range(0.9, 1.1))
					if !(node_type.flags & node_flags.unremovable) {
						instance_create_layer(center_x, center_y, "NodeJudgments", judgment_object, {
							node_inst : id,
							judgment_type : judgment_types.destroy_node,
							target_y : center_y - sprite_height / 2 - 10,
						})
					}
					for (var i = 0; i < array_length(exit_instances); i++) {
						var exit_instance = exit_instances[i];
						instance_create_layer(center_x, center_y, "NodeJudgments", judgment_object, {
							node_inst : id,
							judgment_type : judgment_types.close_connection,
							connection_to_destroy : exit_instances[i],
							silent : true,
							target_x : lerp(center_x, exit_instance.center_x, 0.5),
							target_y : lerp(center_y, exit_instance.center_y, 0.5)
						})
					}
					if (instance_exists(judgment_object)) // root node might not have anything to judge for example
						global.pack_editor.judging_node = id;
					else {
						shake_seconds = 0.5;
						audio_play_sound(not_possible_sound, 10, false, global.pack_zoom_gain);
					}
				}
				else
					global.pack_editor.judging_node = noone;
			}
		}
		else if global.pack_editor.selected_thing == pack_things.wrench {
			if ev_mouse_pressed() {
				node_config()
			}
		}
		else if global.pack_editor.selected_thing == pack_things.placechanger {
			if ev_mouse_pressed() {
				static wrench_sound = agi("snd_ev_use_wrench");
				if !instance_exists(global.pack_editor.node_instance_changing_places) {
					global.pack_editor.node_instance_changing_places = id;
					audio_play_sound(agi("snd_ev_mark_placechanger"), 10, false, global.pack_zoom_gain)
				}
				else {
					if global.pack_editor.node_instance_changing_places == id {
						global.pack_editor.node_instance_changing_places = noone;
						audio_play_sound(agi("snd_ev_mark_placechanger"), 10, false, global.pack_zoom_gain, 0, 0.8)	
					}
					else {
						function try_change_node_places(one, two, do_effects) {
							static not_possible_sound = agi("snd_lorddamage")
							// check if this is a valid swap
							
							if one.max_exits < array_length(two.exit_instances)
									|| two.max_exits < array_length(one.exit_instances)
									|| (!one.can_connect_to_me && array_length(two.connected_to_me) > 0)
									|| (!two.can_connect_to_me && array_length(one.connected_to_me) > 0) {
								if do_effects { 
									one.shake_seconds = 0.5;
									two.shake_seconds = 0.5;
									audio_play_sound(not_possible_sound, 10, false, global.pack_zoom_gain);	
								}
								return;
							}
							
							function change_world_perception(node, other_node) {
								for (var i = 0; i < array_length(node.exit_instances); i++) {
									var exit_instance = node.exit_instances[i]
									if exit_instance == other_node
										continue;
									var index = ev_array_get_index(exit_instance.connected_to_me, node)
									exit_instance.connected_to_me[index] = other_node
								}
								for (var i = 0; i < array_length(node.connected_to_me); i++) {
									var connected_to_node = node.connected_to_me[i]
									if connected_to_node == other_node
										continue;
									var index = ev_array_get_index(connected_to_node.exit_instances, node)
									connected_to_node.exit_instances[index] = other_node
								}
							}
							
							// change how the world perceives us
							change_world_perception(one, two)
							change_world_perception(two, one)
							
							// change how we perceive the world
							var temp_exit_instances = two.exit_instances
							two.exit_instances = one.exit_instances;
							one.exit_instances = temp_exit_instances;
							
							var temp_connected_to_me = two.connected_to_me
							two.connected_to_me = one.connected_to_me
							one.connected_to_me = temp_connected_to_me
							
							// imagine a situation where a and b are connected to each other, and each other only.
							// swapping them like how it is done above, where the outgoing nodes are just traded,
							// will make them both connect to themselves... so we run this check to fix it
							function swap_to_other_if_connected_to_self(me, other_node) {
								for (var i = 0; i < array_length(me.exit_instances); i++) {
									if me.exit_instances[i] == me
										me.exit_instances[i] = other_node;;
								}
								for (var i = 0; i < array_length(me.connected_to_me); i++) {
									if me.connected_to_me[i] == me
										me.connected_to_me[i] = other_node	
								}
							}
							swap_to_other_if_connected_to_self(one, two)
							swap_to_other_if_connected_to_self(two, one)
						
							
							var keep_x = two.center_x
							var keep_y = two.center_y
							move_node_to_position(two, one.center_x - two.center_x_offset, one.center_y - two.center_y_offset)
							move_node_to_position(one, keep_x - one.center_x_offset, keep_y - one.center_y_offset)
							
							if do_effects {
								audio_play_sound(agi("snd_ev_use_placechanger"), 10, false, global.pack_zoom_gain)

								do_placechanger_explosion_particles(one, two)
								do_placechanger_explosion_particles(two, one)
								
								

								do_placechanger_line_particles(one, two)
			
							}
						}
						try_change_node_places(id, global.pack_editor.node_instance_changing_places, true)
						
						global.pack_editor.add_undo_action(function (args) {
							var one = ds_map_find_value(global.pack_editor.node_id_to_instance_map, args.node_id)
							var two = ds_map_find_value(global.pack_editor.node_id_to_instance_map, args.other_id)
							try_change_node_places(one, two, false)
						}, {
							node_id : node_id,
							other_id : global.pack_editor.node_instance_changing_places.node_id,
						})
						
						global.pack_editor.node_instance_changing_places = noone;
					}
				}
			}
		}
		else if global.pack_editor.selected_thing == pack_things.play {
			if ev_mouse_pressed() {
				/*
				if node_type != global.pack_editor.level_node {
					shake_seconds = 0.5;
					audio_play_sound(not_possible_sound, 10, false, global.pack_zoom_gain);	
				}
				else { }
				*/
				if global.is_merged {
					global.pack_editor.start_play_transition(id)
					global.mouse_layer = 1;
				}
				else
					audio_play_sound(snd_reveal, 10, false)
			}
		}
	}

	
	if being_judged && global.pack_editor.selected_thing != pack_things.hammer
		being_judged = false;
	
	if ev_mouse_released() && mouse_moving {
		mouse_moving = false;
		play_pickup_sound(0.8)
		contract_node_instance(id)
		if !spawn_picked_up {
			add_undo_position_action(node_id, x_when_started_moving, y_when_started_moving)
		}
		spawn_picked_up = false;
	}
	if global.pack_editor.node_instance_connecting == id {
		if ev_mouse_held() || global.pack_editor.selected_thing != pack_things.nothing
			global.pack_editor.node_instance_connecting = noone;	
		else if ev_mouse_right_released() {
			global.pack_editor.node_instance_connecting = noone
			var node_inst = get_node_at_position(mouse_x, mouse_y)
			if instance_exists(node_inst) {
				if (!node_inst.can_connect_to_me) {
					node_inst.shake_seconds = 0.5;
					audio_play_sound(not_possible_sound, 10, false, global.pack_zoom_gain);
				}
				else if (array_length(exit_instances) >= max_exits) {
					shake_seconds = 0.5;
					audio_play_sound(not_possible_sound, 10, false, global.pack_zoom_gain);
				}
				else if (!ev_array_contains(exit_instances, node_inst)) {
					// connection successful
					connect_node_instances(id, node_inst)
					var connect_sound = agi("snd_ev_node_connect")
					audio_play_sound(connect_sound, 10, false, global.pack_zoom_gain, 0, random_range(0.9, 1.1))
					
					var old_bount = (node_inst.node_type == global.pack_editor.level_node)
						? node_inst.properties.level.bount
						: noone
					
					global.pack_editor.add_undo_action(function (args) {
						var instance = ds_map_find_value(global.pack_editor.node_id_to_instance_map, args.node_id)
						var exit_instance = ds_map_find_value(global.pack_editor.node_id_to_instance_map, args.exit_id)
						disconnect_node_instances(instance, exit_instance)
						
						if args.old_bount != noone {
							exit_instance.properties.level.bount = args.old_bount
							exit_instance.sync_display_level();
						}
					}, {
						node_id : node_id,
						exit_id : node_inst.node_id,
						old_bount : old_bount
					})
					
					// automatically give brane count to connected level nodes
					if node_inst.node_type == global.pack_editor.level_node && array_length(exit_instances) == 1 {
						if node_type == global.pack_editor.root_node {
							node_inst.properties.level.bount = 1;
							node_inst.display.delete_cached_game_surface();
						}
						else if node_type == global.pack_editor.level_node {
							if properties.level.bount != -1 && properties.level.bount != 999  {
								node_inst.properties.level.bount = properties.level.bount + 1;
								node_inst.display.delete_cached_game_surface();	
							}
							else
								node_inst.properties.level.bount = -1;
						}
					}
					
				}
			}
		}
	}
	if (mouse_moving) {
		move_node_to_position(id, mouse_x - center_x_offset, mouse_y - center_y_offset)
	}


	if (shake_seconds > 0) {
		shake_seconds -= 1/60;
		shake_x_offset = sin(16 * shake_seconds * pi) * 3;
	}
}




function create_falling_arrow_and_number(node_instance, other_node_instance, index, total_exits) {
	var t = global.pack_arrow_progress
	instance_create_layer(
		lerp(node_instance.center_x, other_node_instance.center_x, t),
		lerp(node_instance.center_y, other_node_instance.center_y, t),
		"Debris",
		agi("obj_ev_falling_pack_arrow"))
	var more_than_one_exit = (total_exits > 1)
	var number = (index + 1) * more_than_one_exit
	if number == 0
		exit;
	var t2 = global.pack_number_progress
	instance_create_layer(
		lerp(node_instance.center_x, other_node_instance.center_x, t2),
		lerp(node_instance.center_y, other_node_instance.center_y, t2),
		"Debris",
		agi("obj_ev_falling_pack_number"), {
			number : number	
		})
}
function create_node_shards(node_inst) {
	var manager;
	var size;
	var sprite;
	if node_inst.node_type == global.pack_editor.brand_node {
		sprite = node_inst.brand_sprite
		manager = instance_create_depth(0, 0, 0, agi("obj_ev_node_shard_manager"), {
			sprite : sprite
		})
		node_inst.brand_sprite = noone; // make sure the node doesn't delete the sprite	
		// the sprite is only 6x6, we need it to be 10x10
		size = 10/6;
	}
	else {
		sprite = node_inst.sprite_index
		manager = noone;
		// node sprites are 16x16, we need them to be 10x10
		size = 10/16;	
	}
	repeat (6) {
		instance_create_depth(node_inst.center_x, node_inst.center_y, node_inst.depth, agi("obj_ev_node_shard"), {
			sprite_index : sprite,
			image_speed : 0,
			image_xscale : size,
			image_yscale : size,
			manager : manager
		})	
	}	
}
function node_config() {
	static not_possible_sound = agi("snd_lorddamage")
	if (!node_type.on_config(id)) {
		audio_play_sound(not_possible_sound, 10, false, global.pack_zoom_gain);
		shake_seconds = 0.5;
		return;
	}
	
	static wrench_sound = agi("snd_ev_use_wrench");
	// TODO: use copy_function?
	var properties_string = node_type.write_function(properties)
	audio_play_sound(wrench_sound, 10, false, global.pack_zoom_gain, 0, random_range(0.9, 1.1))
	global.pack_editor.add_undo_action(function (args) {
		var instance = ds_map_find_value(global.pack_editor.node_id_to_instance_map, args.node_id)
		instance.properties = instance.node_type.read_function(args.old_properties)
	}, {
		node_id : node_id,
		old_properties : properties_string
	})
}
function add_undo_position_action(node_id, old_x, old_y) {
	global.pack_editor.add_undo_action(function (args) {
		var instance = ds_map_find_value(global.pack_editor.node_id_to_instance_map, args.node_id)
		move_node_to_position(instance, args.old_x, args.old_y)
	}, {
		node_id : node_id,
		old_x : old_x,
		old_y : old_y
	})
}

function draw_placechanger_highlight() {
	if global.pack_editor.node_instance_changing_places != id
		return;
	gpu_set_fog(true, c_black, 0, 1)
	var increase = dsin(global.editor_time) / 8 + 0.25;
	if node_type == global.pack_editor.level_node {
		var scale = (image_xscale + image_yscale) / 2 + increase / 5;
		draw_sprite_ext(agi("spr_ev_display"), 0, center_x - 112 * scale, center_y - 72 * scale, scale, scale, 0, c_white, 1)
	}
	else {
		var scale = ((image_xscale + image_yscale) / 2) * 5	
		ev_draw_cube(sprite_index, 0, x + shake_x_offset, y, scale + increase * 5, spin_h, spin_v)
	}
	gpu_set_fog(false, c_black, 0, 1)
}

