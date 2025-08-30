event_inherited();
function commit() {
	node_instance.properties.level.bount = int64_safe(bount_textbox.txt, -1);
	node_instance.properties.level.name = name_textbox.txt
	try_level_name_and_rename(node_instance.properties.level, get_all_level_node_instances())
}

var level = node_instance.properties.level;

var txt;
if level.bount >= 0
	txt = string(level.bount);
else
	txt = "???";


name_textbox = instance_create_layer(x - 30, y - 30, "WindowElements", agi("obj_ev_textbox"), {
	empty_text : "Level Name",
	txt : level.name,
	allow_newlines : false,
	automatic_newline: false,
	char_limit : 30,
	base_scale_x : 5,
});
name_warning = instance_create_layer(x + 40, y - 30, "WindowElements", agi("obj_ev_textbox"), {
	txt : "WARNING! To save pack progress for players, EV saves the level's name to a file."
		+ " If you have uploaded this pack, DON'T modify the level names! Otherwise players"
		+ " who saved on those levels will have their save erased!",
	allow_deletion : false,
	char_limit : -1,
	
	allow_deletion : false,
	base_scale_x : 3,
});

bount_textbox = instance_create_layer(x - 54, y, "WindowElements", agi("obj_ev_textbox"), {
	empty_text : "Brane Count",
	txt : txt,
	allow_alphanumeric : false,
	exceptions : "?0123456789",
	char_limit : 3,
	base_scale_x : 2,
});

var copy = instance_create_layer(x + 55, y + 30, "WindowElements", agi("obj_ev_executing_button"), {
	layer_num : 1,
	lvl : level,
	sprite_index : agi("spr_ev_copy"),
	func : function () {
		var str = export_level(lvl);
		clipboard_set_text(str)
		ev_notify("Copied to clipboard!")
	}
})

var edit = instance_create_layer(x + 55, y + 5, "WindowElements", agi("obj_ev_executing_button"), {
	layer_num : 1,
	lvl : level,
	sprite_index : agi("spr_ev_edit_level"),
	func : function () {
		window.commit();
		
		with (global.pack_editor) {
			remember_zoom = zoom;
			remember_camera_x = camera_get_view_x(view_camera[0])
			remember_camera_y = camera_get_view_y(view_camera[0])		
		}
		//global.level = lvl;
		// set to false again once leaving the level editor, where global.editing_pack_level_properties is also updated
		global.editing_pack_level = true;
		global.editing_pack_level_properties = window.node_instance.properties;
		
		// so it remembers what the pack is
		global.pack.starting_node_states = convert_room_nodes_to_structs()
		
		// make the level node not move its display around
		window.node_instance.sync_in_step = false;
		
		// we must reposition and resize this display so it is in the x 0 - 224 and y 0 - 144 region
		
		var display = window.node_instance.display;
		display.layer = layer_get_id("EditTransitionDisplay")
		
		var relative_x = display.x - camera_get_view_x(view_camera[0]);
		var relative_y = display.y - camera_get_view_y(view_camera[0]);
		with (global.pack_editor) {
			var mult = power(zoom_factor, zoom)
			relative_x /= mult;
			relative_y /= mult;
			display.image_xscale /= mult;
			display.image_yscale /= mult;
			display.scale_x_start = display.image_xscale
			display.scale_y_start = display.image_yscale
		}
		display.x = relative_x;
		display.y = relative_y;
		display.xstart = relative_x;
		display.ystart = relative_y;
	
		camera_set_view_pos(view_camera[0], 0, 0);
		camera_set_view_size(view_camera[0], 224, 144);

		// sounds cool
		
		if global.is_merged { 
			global.ambience_is_playing = false;
			global.ambience_shutdown = false;
			agi("scr_play_ambience")(-4, true)
		}
		
		global.editor.edit_level_transition(lvl, display)
		lvl.music = global.music_names[1];
		global.void_radio_disable_stack++;
		//room_goto(global.editor_room)
	}
})


add_child(bount_textbox);
add_child(name_textbox);
add_child(name_warning);
add_child(copy);
add_child(edit);

is_brand_room = is_level_brand_room(level)

elements_depth = layer_get_depth("WindowElements")