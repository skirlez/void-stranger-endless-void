function move_node_to_position(instance, new_x, new_y) {
	if (new_y < 0)
		new_y = 0
	if (new_y > room_height - instance.sprite_height)
		new_y = room_height - instance.sprite_height
	if (new_x < 0)
		new_x = 0
	if (new_x > room_width - instance.sprite_width)
		new_x = room_width - instance.sprite_width
	instance.x = new_x
	instance.y = new_y
	instance.center_x = new_x + center_x_offset
	instance.center_y = new_y + center_y_offset
		
	line_drawer.update()
	for (var i = 0; i < array_length(instance.connected_to_me); i++) {
		instance.connected_to_me[i].line_drawer.update()
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
		ev_draw_cube(sprite_index, 0, x + shake_x_offset, y, scale + increase * 5, spin_h, spin_v, false)
	}
	gpu_set_fog(false, c_black, 0, 1)
}

